//
//  MapViewController.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 10/29/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureMapView()
    
    let tree = Tree(coordinate: CLLocationCoordinate2D(latitude: 42.3361, longitude: -71.1677))
    mapView.addAnnotation(tree)
  }
  
  func configureMapView() {
    mapView.mapType = .satellite
    
    let initialLocation = CLLocation(latitude: 42.3361, longitude: -71.1677)
    let initialRegion = MKCoordinateRegion(center: initialLocation.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    mapView.setRegion(initialRegion, animated: false)
  }
  

}

