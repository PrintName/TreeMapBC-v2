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

class MapViewController: UIViewController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  @IBOutlet weak var mapView: MKMapView!
  
  var annotationClustering = true
  
  var bottomSheetVC: BottomSheetViewController!
  
  let treeAnnotations = TreeAnnotations()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureMapView()
    addBottomSheetView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    treeAnnotations.createDefaultTreeAnnotations()
    mapView.addAnnotations(treeAnnotations.currentArray)
    setBottomSheetImpact(treeAnnotations.currentImpact)
    bottomSheetVC.bottomSheetSubtitle.text = "\(treeAnnotations.currentArray.count) Trees"
  }
  
  private func configureMapView() {
    mapView.delegate = self
    
    let initialLocation = CLLocation(latitude: 42.3361, longitude: -71.1677)
    let initialRegion = MKCoordinateRegion(center: initialLocation.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    mapView.setRegion(initialRegion, animated: false)
    
    mapView.register(TreeAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
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
    if annotation is MKUserLocation {
      return nil
    } else if annotation is MKClusterAnnotation {
      annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)!
    } else {
      annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)!
    }
    if annotationClustering == true {
      annotationView.clusteringIdentifier = "tree"
    } else {
      annotationView.clusteringIdentifier = nil
    }
    return annotationView
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    let markerView = view as! MKMarkerAnnotationView
    markerView.markerTintColor = .highlightColor
    markerView.glyphTintColor = .white
    
    var title = "Title"
    var subtitle = "Subtitle"
    var impact = TreeAnnotation.Impact(carbonOffset: 0, distanceDriven: 0, carbonStorage: 0, pollutionRemoved: 0, waterIntercepted: 0)
    
    if let treeAnnotation = view.annotation as? TreeAnnotation {
      title = treeAnnotation.commonName
      subtitle = treeAnnotation.botanicalName
      impact = treeAnnotation.impact
    }
    
    if let clusterAnnotation = view.annotation as? MKClusterAnnotation {
      let treeAnnotations = clusterAnnotation.memberAnnotations as! [TreeAnnotation]
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
    bottomSheetVC.bottomSheetTitle.text = title
    bottomSheetVC.bottomSheetSubtitle.text = subtitle
    setBottomSheetImpact(impact)
  }
  
  func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    let markerView = view as! MKMarkerAnnotationView
    markerView.markerTintColor = .primaryColor
    if markerView.glyphImage != nil {
      markerView.glyphTintColor = .secondaryColor
    }
    bottomSheetVC.bottomSheetTitle.text = "TreeMap: Boston College"
    bottomSheetVC.bottomSheetSubtitle.text = "\(treeAnnotations.currentArray.count) Trees"
    setBottomSheetImpact(treeAnnotations.currentImpact)
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if mapView.region.span.latitudeDelta < 0.002 {
      if annotationClustering == true {
        toggleAnnotationClustering()
      }
    } else if annotationClustering == false {
      toggleAnnotationClustering()
    }
  }
  
  private func toggleAnnotationClustering() {
    annotationClustering.toggle()
    mapView.removeAnnotations(treeAnnotations.currentArray)
    mapView.addAnnotations(treeAnnotations.currentArray)
  }
}
