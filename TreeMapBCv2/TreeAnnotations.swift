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
        guard let latitude = object.value(forKey: "latitude") as? Double,
        let longitude = object.value(forKey: "longitude") as? Double,
        let campus = object.value(forKey: "campus") as? String,
        let dbh = object.value(forKey: "dbh") as? Double,
        let carbonOffset = object.value(forKey: "carbonOffset") as? Double,
        let distanceDriven = object.value(forKey: "distanceDriven") as? Double,
        let carbonStorage = object.value(forKey: "carbonStorage") as? Double,
        let pollutionRemoved = object.value(forKey: "pollutionRemoved") as? Double,
        let waterIntercepted = object.value(forKey: "waterIntercepted") as? Double,
        let species = object.value(forKey: "species") as? Species
        else {
          print("\n❗️ERROR: Could not decode tree objects❗️\n")
          return
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let commonName = species.commonName ?? ""
        let botanicalName = species.botanicalName ?? ""
        let detail = species.detail ?? ""
        
        let treeAnnotation = TreeAnnotation(coordinate: coordinate, commonName: commonName, botanicalName: botanicalName, detail: detail, campus: campus, dbh: dbh, impact: TreeAnnotation.Impact(carbonOffset: carbonOffset, distanceDriven: distanceDriven, carbonStorage: carbonStorage, pollutionRemoved: pollutionRemoved, waterIntercepted: waterIntercepted))
        treeAnnotationArray.append(treeAnnotation)
        
        treeImpact.carbonOffset += carbonOffset
        treeImpact.distanceDriven += distanceDriven
        treeImpact.carbonStorage += carbonStorage
        treeImpact.pollutionRemoved += pollutionRemoved
        treeImpact.waterIntercepted += waterIntercepted
      }
    } catch let error as NSError {
      print("\n❗️ERROR: Could not fetch trees❗️\n\(error)\n")
    }
    
    array = treeAnnotationArray
    impact = treeImpact
  }
  
  func createFilteredTreeAnnotations(species: Species?, campus: String?) {
    var filterPredicates = [NSPredicate]()
    if let commonName = species?.commonName {
      filterPredicates.append(NSPredicate(format: "ANY species.commonName == %@", commonName))
    }
    if let campus = campus {
      filterPredicates.append(NSPredicate(format: "campus == %@", campus))
    }
    if !filterPredicates.isEmpty {
      let filterCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: filterPredicates)
      createTreeAnnotations(filterCompoundPredicate: filterCompoundPredicate)
    }
  }
}
