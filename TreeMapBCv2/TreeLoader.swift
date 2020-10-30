//
//  TreeLoader.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 10/30/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import SwiftCSV

extension UIApplicationDelegate {
  func preloadTreeData () {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    clearData()
    
    let entity = NSEntityDescription.entity(forEntityName: "Tree", in: managedContext)!
    
    let treeDataArray = parseBCTreesCSV()
    for treeData in treeDataArray {
      let tree = NSManagedObject(entity: entity, insertInto: managedContext)
      tree.setValue(treeData.latitude, forKeyPath: "latitude")
      tree.setValue(treeData.longitude, forKeyPath: "longitude")
    }
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("❗️ERROR: Could not save❗️\n\(error)")
    }
  }
  
  func parseBCTreesCSV() -> [(tag: String, latitude: Double, longitude: Double, commonName: String, botanicalName: String, campus: String, dbh: Int, status: String, carbonOffset: Double, distanceDriven: Double, carbonStorage: Double, pollutionRemoved: Double, waterIntercepted: Double)] {
    // Load CSV file into Tree Data Array
    var treeDataArray: [(tag: String, latitude: Double, longitude: Double, commonName: String, botanicalName: String, campus: String, dbh: Int, status: String, carbonOffset: Double, distanceDriven: Double, carbonStorage: Double, pollutionRemoved: Double, waterIntercepted: Double)] = []
    let filePath = Bundle.main.url(forResource: "BCTrees", withExtension: "csv")!
    do {
      let csvFile: CSV = try CSV(url: filePath)
      let rows = csvFile.enumeratedRows
      for row in rows {
        let tag = row[0]
        let latitude = Double(row[1]) ?? 0.0
        let longitude = Double(row[2]) ?? 0.0
        let commonName = row[3]
        let botanicalName = row[4]
        let campus = row[5]
        let dbh = Int(row[6]) ?? 0
        let status = row[7]
        let carbonOffset = Double(row[8]) ?? 0
        let distanceDriven = carbonOffset * 2.475
        let carbonStorage = Double(row[9]) ?? 0
        let pollutionRemoved = Double(row[10]) ?? 0
        let waterIntercepted = (Double(row[11]) ?? 0) * 7.48052
        if status == "Living" {
          let treeData = (tag: tag, latitude: latitude, longitude: longitude, commonName: commonName, botanicalName: botanicalName, campus: campus, dbh: dbh, status: status, carbonOffset: carbonOffset, distanceDriven: distanceDriven, carbonStorage: carbonStorage, pollutionRemoved: pollutionRemoved, waterIntercepted: waterIntercepted)
          treeDataArray.append(treeData)
        }
      }
    } catch {
      print("❗️ERROR: Missing CSV file❗️")
    }
    return treeDataArray
  }
  
  func clearData () {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Tree")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
      try managedContext.execute(deleteRequest)
      managedContext.reset()
    } catch let error as NSError {
      print("ERROR: Could not clear data❗️\n\(error)")
    }
  }
}
