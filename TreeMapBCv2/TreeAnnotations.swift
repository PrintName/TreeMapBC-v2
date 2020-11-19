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
  var array: [TreeAnnotation]!
  var impact: TreeAnnotation.Impact!
  
  func createTreeAnnotations(filterCompoundPredicate: NSCompoundPredicate?) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    var treeAnnotationArray = [TreeAnnotation]()
    var treeImpact = TreeAnnotation.Impact()
    
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tree")
    if let filterCompoundPredicate = filterCompoundPredicate {
      fetchRequest.predicate = filterCompoundPredicate
    }
    
    do {
      let treeObjects = try managedObjectContext.fetch(fetchRequest)
      
      for object in treeObjects {
        let tag = object.value(forKey: "tag") as! Int
        let latitude = object.value(forKey: "latitude") as! Double
        let longitude = object.value(forKey: "longitude") as! Double
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let campus = object.value(forKey: "campus") as! String
        let dbh = object.value(forKey: "dbh") as! Double
        let carbonOffset = object.value(forKey: "carbonOffset") as! Double
        let distanceDriven = object.value(forKey: "distanceDriven") as! Double
        let carbonStorage = object.value(forKey: "carbonStorage") as! Double
        let pollutionRemoved = object.value(forKey: "pollutionRemoved") as! Double
        let waterIntercepted = object.value(forKey: "waterIntercepted") as! Double
        
        let species = object.value(forKey: "species") as! Species
        let commonName = species.commonName!
        let botanicalName = species.botanicalName!
        
        let treeAnnotation = TreeAnnotation(tag: tag, coordinate: coordinate, commonName: commonName, botanicalName: botanicalName, campus: campus, dbh: dbh, impact: TreeAnnotation.Impact(carbonOffset: carbonOffset, distanceDriven: distanceDriven, carbonStorage: carbonStorage, pollutionRemoved: pollutionRemoved, waterIntercepted: waterIntercepted))
        treeAnnotationArray.append(treeAnnotation)
        
        treeImpact.carbonOffset += carbonOffset
        treeImpact.distanceDriven += distanceDriven
        treeImpact.carbonStorage += carbonStorage
        treeImpact.pollutionRemoved += pollutionRemoved
        treeImpact.waterIntercepted += waterIntercepted
      }
      
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    array = treeAnnotationArray
    impact = treeImpact
  }
  
//  func filterTreeAnnotations(commonName: String?, botanicalName: String?, campus: String?, dbh: Double?) {
//    var filterPredicates = [NSPredicate]()
//    if let commonName = commonName {
//      filterPredicates.append(NSPredicate(format: "ANY species.commonName == %@", commonName))
//    }
//    if let botanicalName = botanicalName {
//      filterPredicates.append(NSPredicate(format: "ANY species.botanicalName == %@", botanicalName))
//    }
//    if let campus = campus {
//      filterPredicates.append(NSPredicate(format: "campus == %@", campus))
//    }
//    if let dbh = dbh {
//      filterPredicates.append(NSPredicate(format: "dbh == %@", dbh))
//    }
//    if !filterPredicates.isEmpty {
//      let filterCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: filterPredicates)
//      treeAnnotations.createTreeAnnotations(filterCompoundPredicate: filterCompoundPredicate)
//      addTreeAnnotations()
//    }
//  }
}
