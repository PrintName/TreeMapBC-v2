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
  var treeAnnotationArray = [TreeAnnotation]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureMapView()
    addBottomSheetView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    treeAnnotationArray = createTreeAnnotations()
    mapView.addAnnotations(treeAnnotationArray)
  }
  
  func configureMapView() {
    mapView.delegate = self
    
    let initialLocation = CLLocation(latitude: 42.3361, longitude: -71.1677)
    let initialRegion = MKCoordinateRegion(center: initialLocation.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    mapView.setRegion(initialRegion, animated: false)
    
    mapView.register(TreeAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
  }
  
  func createTreeAnnotations() -> [TreeAnnotation] {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    var treeAnnotationArray = [TreeAnnotation]()
    
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tree")
    do {
      let treeObjects = try managedObjectContext.fetch(fetchRequest)
      for object in treeObjects {
        let tag = object.value(forKey: "tag") as! Int
        let latitude = object.value(forKey: "latitude") as! Double
        let longitude = object.value(forKey: "longitude") as! Double
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let commonName = object.value(forKey: "commonName") as! String
        let botanicalName = object.value(forKey: "botanicalName") as! String
        let campus = object.value(forKey: "campus") as! String
        let dbh = object.value(forKey: "dbh") as! Double
        let carbonOffset = object.value(forKey: "carbonOffset") as! Double
        let distanceDriven = object.value(forKey: "distanceDriven") as! Double
        let carbonStorage = object.value(forKey: "carbonStorage") as! Double
        let pollutionRemoved = object.value(forKey: "pollutionRemoved") as! Double
        let waterIntercepted = object.value(forKey: "waterIntercepted") as! Double
        let treeAnnotation = TreeAnnotation(title: commonName, subtitle: botanicalName, tag: tag, coordinate: coordinate, commonName: commonName, botanicalName: botanicalName, campus: campus, dbh: dbh, impact: TreeAnnotation.Impact(carbonOffset: carbonOffset, distanceDriven: distanceDriven, carbonStorage: carbonStorage, pollutionRemoved: pollutionRemoved, waterIntercepted: waterIntercepted))
        treeAnnotationArray.append(treeAnnotation)
      }
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    return treeAnnotationArray
  }
  
  func addBottomSheetView() {
    let bottomSheetVC = BottomSheetViewController()
    
    self.addChild(bottomSheetVC)
    self.view.addSubview(bottomSheetVC.view)
    
    let height = view.frame.height
    let width  = view.frame.width
    bottomSheetVC.view.frame = .init(x: 0, y: self.view.frame.maxY, width: width, height: height)
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
      subtitle = "And \(otherSpeciesCount) other species"
    }
    print()
    print(title)
    print(subtitle)
    print(impact)
  }
  
  func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    let markerView = view as! MKMarkerAnnotationView
    markerView.markerTintColor = .primaryColor
    if markerView.glyphImage != nil {
      markerView.glyphTintColor = .secondaryColor
    }
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
    mapView.removeAnnotations(treeAnnotationArray)
    mapView.addAnnotations(treeAnnotationArray)
  }
}
