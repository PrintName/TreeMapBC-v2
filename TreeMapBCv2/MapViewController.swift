//
//  MapViewController.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 10/29/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import Cluster

class MapViewController: UIViewController {
  // MARK: - Properties
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var searchView: PassthroughView!
  @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
  
  var bottomSheetVC: BottomSheetViewController!
  
  let treeAnnotations = TreeAnnotations()
  
  var locationManager: CLLocationManager?
  
  lazy var clusterManager: ClusterManager = { [unowned self] in
    let manager = ClusterManager()
    manager.delegate = self
    manager.maxZoomLevel = 18
    manager.minCountForClustering = 2
    manager.clusterPosition = .nearCenter
    return manager
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureMapView()
    configureLocationManager()
    addBottomSheetView()
    addKeyboardNotifications()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    searchView.layer.shadowRadius = 4
    searchView.layer.shadowOpacity = 0.5
    searchView.layer.shadowColor = UIColor.black.cgColor
    searchView.layer.shadowOffset = .zero
  }
  
  private func configureMapView() {
    mapView.delegate = self
    
    let initialLocation = CLLocation(latitude: 42.3361, longitude: -71.1677)
    let mapCamera = MKMapCamera(lookingAtCenter: initialLocation.coordinate, fromDistance: 4000, pitch: 22.5, heading: 0)
    mapView.setCamera(mapCamera, animated: false)
    mapView.isPitchEnabled = false
    
    if mapView.mapType == .satelliteFlyover {
      fatalError("Please tell Allen about this error!")
    }
    
    mapView.layoutMargins.bottom = 165
    
    mapView.register(TreeAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    mapView.register(TreeClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
  }
  
  private func addBottomSheetView() {
    bottomSheetVC = BottomSheetViewController()
    
    addChild(bottomSheetVC)
    view.addSubview(bottomSheetVC.view)
    
    let height = view.frame.height
    let width  = view.frame.width
    bottomSheetVC.view.frame = .init(x: 0, y: view.frame.maxY, width: width, height: height)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    treeAnnotations.createTreeAnnotations(filterCompoundPredicate: nil)
    addTreeAnnotations()
  }
  
  private func addTreeAnnotations() {
    clusterManager.removeAll()
    clusterManager.add(treeAnnotations.array)
    clusterManager.reload(mapView: mapView)
    setBottomSheetImpact(treeAnnotations.impact)
    bottomSheetVC.bottomSheetSubtitle.text = "\(treeAnnotations.array.count) trees"
  }
  
  private func addKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "SearchBarSegue") {
      let searchVC = segue.destination as! SearchViewController
      searchVC.delegate = self
    }
  }
  
  // MARK: - Actions
  
  @objc func keyboardWillShow(_ notification: NSNotification) {
    let info = notification.userInfo!
    let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let topSafeArea = view.safeAreaInsets.top
    let screenHeight = UIScreen.main.bounds.height - topSafeArea
    let keyboardHeight = keyboardFrame.height
    
    searchViewHeight.constant = screenHeight - keyboardHeight - 20
    bottomSheetVC.animateHide()
    fadeMapView()
  }
  
  @objc func keyboardWillHide(_ notification: NSNotification) {
    bottomSheetVC.animateShow()
    showMapView()
  }
  
  private func showMapView() {
    mapView.isUserInteractionEnabled = true
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self = self else { return }
      self.mapView.alpha = 1
      self.searchView.layer.shadowOpacity = 0.5
    })
  }
  
  private func fadeMapView() {
    mapView.isUserInteractionEnabled = false
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self = self else { return }
      self.mapView.alpha = 0.5
      self.searchView.layer.shadowOpacity = 0
    })
  }
  
  private func setBottomSheetImpact(_ impact: TreeAnnotation.Impact) {
    bottomSheetVC.bottomSheetImpact.text =
    """
    • CO2 Offset: \(impact.carbonOffset.formatted) lb
        (est. \(impact.distanceDriven.formatted) mi driven)
    • Total Carbon Stored: \(impact.carbonStorage.formatted) lb
    • Air Pollution Removed: \(impact.pollutionRemoved.formatted) oz
    • Rainfall Runoff Intercepted: \(impact.waterIntercepted.formatted) gal
    """
  }
}

// MARK: - MapViewDelegate

extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let annotationView: MKAnnotationView
    switch annotation {
    case is ClusterAnnotation:
      annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)!
    case is TreeAnnotation:
      annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)!
    default:
      return nil
    }
    return annotationView
  }
  
  public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    let userLocationView = mapView.view(for: mapView.userLocation)
    userLocationView?.isUserInteractionEnabled = false
    userLocationView?.isEnabled = false
    userLocationView?.canShowCallout = false
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    var title: String!
    var subtitle: String!
    var detail: String!
    var impact = TreeAnnotation.Impact(carbonOffset: 0, distanceDriven: 0, carbonStorage: 0, pollutionRemoved: 0, waterIntercepted: 0)
    
    if let clusterAnnotation = view.annotation as? ClusterAnnotation {
      view.layer.backgroundColor = .highlightColor
      let treeAnnotations = clusterAnnotation.annotations as! [TreeAnnotation]
      var commonNameCounts: [String: Int] = [:]
      for annotation in treeAnnotations {
        impact.carbonOffset += annotation.impact.carbonOffset
        impact.distanceDriven += annotation.impact.distanceDriven
        impact.carbonStorage += annotation.impact.carbonStorage
        impact.pollutionRemoved += annotation.impact.pollutionRemoved
        impact.waterIntercepted += annotation.impact.waterIntercepted
        commonNameCounts[annotation.commonName, default: 0] += 1
      }
      let (commonName, _) = commonNameCounts.max(by: { $0.1 < $1.1 })!
      title = commonName
      let otherSpeciesCount = commonNameCounts.count - 1
      subtitle = "+ \(otherSpeciesCount) other species"
      // Get detail
      let speciesRequest = NSFetchRequest<NSManagedObject>(entityName: "Species")
      speciesRequest.predicate = NSPredicate(format: "commonName == %@", commonName)
      if let fetchedSpecies = try? managedContext.fetch(speciesRequest) {
        if fetchedSpecies.count > 0, let species = fetchedSpecies[0] as? Species {
          detail = species.detail
        }
      }
    }
    
    if let treeAnnotation = view.annotation as? TreeAnnotation {
      let markerView = view as! TreeAnnotationView
      markerView.backgroundColor = .highlightColor
      markerView.layer.borderColor = UIColor.white.cgColor
      markerView.glyphImageView.tintColor = .white
      title = treeAnnotation.commonName
      subtitle = treeAnnotation.botanicalName
      detail = treeAnnotation.detail
      impact = treeAnnotation.impact
    }
    
    bottomSheetVC.bottomSheetTitle.text = title
    bottomSheetVC.bottomSheetSubtitle.text = subtitle
    bottomSheetVC.bottomSheetDetail.text = detail
    setBottomSheetImpact(impact)
   
    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
      view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
    })
  }
  
  func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    if let clusterView = view as? ClusterAnnotationView {
      clusterView.backgroundColor = .primaryColor
    }
    if let markerView = view as? TreeAnnotationView {
      markerView.backgroundColor = .primaryColor
      markerView.layer.borderColor = .secondaryColor
      markerView.glyphImageView.tintColor = .treeAnnotationColor
    }
    bottomSheetVC.bottomSheetTitle.text = "TreeMap: Boston College"
    bottomSheetVC.bottomSheetSubtitle.text = "\(treeAnnotations.array.count) trees"
    bottomSheetVC.bottomSheetDetail.text = "Boston College is home to over 100 species of trees, from the Littleleaf Linden to the mighty Sequoia. Each and every tree is crucial in reducing BC's carbon footprint and creating a more sustainable campus."
    setBottomSheetImpact(treeAnnotations.impact)
   
   UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
      view.transform = CGAffineTransform(scaleX: 1, y: 1)
   })
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    clusterManager.reload(mapView: mapView)
  }
}

// MARK: - ClusterManagerDelegaste

extension MapViewController: ClusterManagerDelegate {
  func cellSize(for zoomLevel: Double) -> Double? {
    return 40
  }
  
  func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
    return !(annotation is MKUserLocation)
  }
}

// MARK: - SearchFilterDelegate

extension MapViewController: SearchFilterDelegate {
  func speciesFilterSelected(species: Species, campus: String?) {
    treeAnnotations.createFilteredTreeAnnotations(species: species, campus: campus)
    addTreeAnnotations()
  }
  
  func speciesFilterCanceled() {
    treeAnnotations.createTreeAnnotations(filterCompoundPredicate: nil)
    addTreeAnnotations()
  }
}

// MARK: - LocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
  func configureLocationManager() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.requestWhenInUseAuthorization()
  }
}
