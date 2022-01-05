//
//  TreeData.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 10/30/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import SwiftCSV

class TreeData {
  func preloadTreeData() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    clearDataEntity(entityName: "Species")
    clearDataEntity(entityName: "Tree")
    
    let speciesEntity = NSEntityDescription.entity(forEntityName: "Species", in: managedContext)!
    let treeEntity = NSEntityDescription.entity(forEntityName: "Tree", in: managedContext)!
    
    let treeDetailDict = parseTreeDetailCSV()
    let treeDataArray = parseBCTreesCSV()
    
    for treeData in treeDataArray {
      // Tree
      let tree = NSManagedObject(entity: treeEntity, insertInto: managedContext) as! Tree
      tree.setValue(treeData.latitude, forKeyPath: "latitude")
      tree.setValue(treeData.longitude, forKeyPath: "longitude")
      tree.setValue(treeData.campus, forKeyPath: "campus")
      tree.setValue(treeData.dbh, forKeyPath: "dbh")
      tree.setValue(treeData.carbonOffset, forKeyPath: "carbonOffset")
      tree.setValue(treeData.distanceDriven, forKeyPath: "distanceDriven")
      tree.setValue(treeData.carbonStorage, forKeyPath: "carbonStorage")
      tree.setValue(treeData.pollutionRemoved, forKeyPath: "pollutionRemoved")
      tree.setValue(treeData.waterIntercepted, forKeyPath: "waterIntercepted")
      // Species
      var species: Species!
      let speciesRequest = NSFetchRequest<NSManagedObject>(entityName: "Species")
      speciesRequest.predicate = NSPredicate(format: "commonName == %@", treeData.commonName)
      // Species already exists
      if let fetchedSpecies = try? managedContext.fetch(speciesRequest) {
        if fetchedSpecies.count > 0 {
          species = fetchedSpecies[0] as? Species
        }
      }
      // Create new species
      if species == nil {
        species = NSManagedObject(entity: speciesEntity, insertInto: managedContext) as? Species
        species.setValue(treeData.commonName, forKey: "commonName")
        species.setValue(treeData.botanicalName, forKey: "botanicalName")
        if let detail = treeDetailDict[treeData.commonName] {
          species.setValue(detail, forKey: "detail")
        }
      }
      species.addToTrees(tree)
    }
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("\n❗️ERROR: Could not save❗️\n\(error)\n")
    }
  }
  
  private func parseBCTreesCSV() -> [(latitude: Double, longitude: Double, commonName: String, botanicalName: String, campus: String, dbh: Int, carbonOffset: Double, distanceDriven: Double, carbonStorage: Double, pollutionRemoved: Double, waterIntercepted: Double)] {
    // Load CSV file into Tree Data Array
    var treeDataArray: [(latitude: Double, longitude: Double, commonName: String, botanicalName: String, campus: String, dbh: Int, carbonOffset: Double, distanceDriven: Double, carbonStorage: Double, pollutionRemoved: Double, waterIntercepted: Double)] = []
    let filePath = Bundle.main.url(forResource: "BCTrees", withExtension: "csv")! // TODO: Replace with online hosted CSV
    do {
      let csvFile: CSV = try CSV(url: filePath)
      let rows = csvFile.enumeratedRows
      for row in rows {
        let latitude = Double(row[0]) ?? 0.0
        let longitude = Double(row[1]) ?? 0.0
        let commonName = row[2]
        let botanicalName = row[3]
        let campus = row[4]
        let dbh = Int(row[5]) ?? 0
        let carbonOffset = Double(row[6]) ?? 0
        let distanceDriven = carbonOffset * 2.475 // based on average US automobile CO2 data
        let carbonStorage = Double(row[7]) ?? 0
        let pollutionRemoved = Double(row[8]) ?? 0
        let waterIntercepted = (Double(row[9]) ?? 0) * 7.48052 // cuft -> gallon
        let treeData = (latitude: latitude, longitude: longitude, commonName: commonName, botanicalName: botanicalName, campus: campus, dbh: dbh, carbonOffset: carbonOffset, distanceDriven: distanceDriven, carbonStorage: carbonStorage, pollutionRemoved: pollutionRemoved, waterIntercepted: waterIntercepted)
        treeDataArray.append(treeData)
      }
    } catch {
      print("\n❗️ERROR: Missing BC Trees CSV file❗️\n")
    }
    return treeDataArray
  }
  
  private func parseTreeDetailCSV() -> [String: String]  {
    var treeDetailDict = [String: String]()
    let filePath = Bundle.main.url(forResource: "TreeDetail", withExtension: "csv")!
    do {
      let csvFile: CSV = try CSV(url: filePath)
      let rows = csvFile.enumeratedRows
      for row in rows {
        let commonName = row[0]
        let detail = row[1]
        treeDetailDict[commonName] = detail
      }
    } catch {
      print("\n❗️ERROR: Missing Tree Detail CSV file❗️\n")
    }
    return treeDetailDict
  }
  
  private func clearDataEntity(entityName: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
      try managedContext.execute(deleteRequest)
      managedContext.reset()
    } catch let error as NSError {
      print("\n❗️ERROR: Could not clear data❗️\n\(error)\n")
    }
  }
}
