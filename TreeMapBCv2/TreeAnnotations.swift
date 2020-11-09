//
//  TreeAnnotations.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 11/9/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TreeAnnotations {
  var currentArray: [TreeAnnotation]!
  private var defaultArray: [TreeAnnotation]!
  
  func createDefaultTreeAnnotations() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
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
    defaultArray = treeAnnotationArray
    currentArray = defaultArray
  }
}