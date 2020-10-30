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

  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureMapView()
  }
  
  func configureMapView() {
    mapView.mapType = .satellite
    
    let initialLocation = CLLocation(latitude: 42.3361, longitude: -71.1677)
    let initialRegion = MKCoordinateRegion(center: initialLocation.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    mapView.setRegion(initialRegion, animated: false)
    
    mapView.register(TreeAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    let treeAnnotationArray = createTreeAnnotations()
    mapView.addAnnotations(treeAnnotationArray)
  }
  
  func createTreeAnnotations() -> [TreeAnnotation] {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    var treeAnnotationArray = [TreeAnnotation]()
    
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tree")
    do {
      let treeObjects = try managedObjectContext.fetch(fetchRequest)
      for object in treeObjects {
        let latitude = object.value(forKey: "latitude") as! Double
        let longitude = object.value(forKey: "longitude") as! Double
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let treeAnnotation = TreeAnnotation(coordinate: coordinate)
        treeAnnotationArray.append(treeAnnotation)
      }
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    return treeAnnotationArray
  }

}

