//
//  MapViewController.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 10/29/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Cluster

class MapViewController: UIViewController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  @IBOutlet weak var mapView: MKMapView!
  
  var annotationClustering = true
  
  var bottomSheetVC: BottomSheetViewController!
  
  let treeAnnotations = TreeAnnotations()
  
  lazy var clusterManager: ClusterManager = { [unowned self] in
    let manager = ClusterManager()
    manager.delegate = self
    manager.maxZoomLevel = 18
    manager.minCountForClustering = 2
    manager.clusterPosition = .nearCenter
    return manager
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureMapView()
    addBottomSheetView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    treeAnnotations.createDefaultTreeAnnotations()
    clusterManager.add(treeAnnotations.currentArray)
    clusterManager.reload(mapView: mapView)
    setBottomSheetImpact(treeAnnotations.currentImpact)
    bottomSheetVC.bottomSheetSubtitle.text = "\(treeAnnotations.currentArray.count) Trees"
  }
  
  private func configureMapView() {
    mapView.delegate = self
    
    let initialLocation = CLLocation(latitude: 42.3361, longitude: -71.1677)
    let initialRegion = MKCoordinateRegion(center: initialLocation.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    mapView.setRegion(initialRegion, animated: false)
    
    mapView.register(TreeAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    mapView.register(TreeClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
  }
  
  private func addBottomSheetView() {
    bottomSheetVC = BottomSheetViewController()
    
    self.addChild(bottomSheetVC)
    self.view.addSubview(bottomSheetVC.view)
    
    let height = view.frame.height
    let width  = view.frame.width
    bottomSheetVC.view.frame = .init(x: 0, y: self.view.frame.maxY, width: width, height: height)
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
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    var title = "Title"
    var subtitle = "Subtitle"
    var impact = TreeAnnotation.Impact(carbonOffset: 0, distanceDriven: 0, carbonStorage: 0, pollutionRemoved: 0, waterIntercepted: 0)
    
    if let clusterAnnotation = view.annotation as? ClusterAnnotation {
      view.layer.backgroundColor = .highlightColor
      let treeAnnotations = clusterAnnotation.annotations as! [TreeAnnotation]
      var treeNameCounts: [String: Int] = [:]
      for annotation in treeAnnotations {
        impact.carbonOffset += annotation.impact.carbonOffset
        impact.distanceDriven += annotation.impact.distanceDriven
        impact.carbonStorage += annotation.impact.carbonStorage
        impact.pollutionRemoved += annotation.impact.pollutionRemoved
        impact.waterIntercepted += annotation.impact.waterIntercepted
        treeNameCounts[annotation.commonName, default: 0] += 1
      }
      let (treeName, _) = treeNameCounts.max(by: { $0.1 < $1.1 })!
      title = treeName
      let otherSpeciesCount = treeNameCounts.count - 1
      subtitle = "+ \(otherSpeciesCount) other species"
    }
    
    if let treeAnnotation = view.annotation as? TreeAnnotation {
      let markerView = view as! TreeAnnotationView
      markerView.backgroundColor = .highlightColor
      markerView.layer.borderColor = UIColor.white.cgColor
      markerView.glyphImageView.tintColor = .white
      title = treeAnnotation.commonName
      subtitle = treeAnnotation.botanicalName
      impact = treeAnnotation.impact
    }
    
    bottomSheetVC.bottomSheetTitle.text = title
    bottomSheetVC.bottomSheetSubtitle.text = subtitle
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
      markerView.glyphImageView.tintColor = .secondaryColor
    }
    bottomSheetVC.bottomSheetTitle.text = "TreeMap: Boston College"
    bottomSheetVC.bottomSheetSubtitle.text = "\(treeAnnotations.currentArray.count) Trees"
    setBottomSheetImpact(treeAnnotations.currentImpact)
   
   UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
      view.transform = CGAffineTransform(scaleX: 1, y: 1)
   })
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    clusterManager.reload(mapView: mapView) { finished in
//      print(finished)
    }
  }
}

extension MapViewController: ClusterManagerDelegate {
  func cellSize(for zoomLevel: Double) -> Double? {
    return min(220-(zoomLevel*10), 80)
  }
  
  func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
    return !(annotation is MKUserLocation)
  }
}
