//
//  AppDelegate.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 10/29/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import SwiftCSV

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
  
  // MARK: - Core Data stack
  
  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "TreeMapBCv2")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
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
        let latitude = Double(row[1])!
        let longitude = Double(row[2])!
        let commonName = row[3]
        let botanicalName = row[4]
        let campus = row[5]
        let dbh = Int(row[6])!
        let status = row[7]
        let carbonOffset = Double(row[8])!
        let distanceDriven = carbonOffset * 2.475
        let carbonStorage = Double(row[9])!
        let pollutionRemoved = Double(row[10])!
        let waterIntercepted = Double(row[11])! * 7.48052
        let treeData = (tag: tag, latitude: latitude, longitude: longitude, commonName: commonName, botanicalName: botanicalName, campus: campus, dbh: dbh, status: status, carbonOffset: carbonOffset, distanceDriven: distanceDriven, carbonStorage: carbonStorage, pollutionRemoved: pollutionRemoved, waterIntercepted: waterIntercepted)
        treeDataArray.append(treeData)
      }
    } catch {
      print("❗️ERROR: CSV file is incorrectly formatted.")
    }
    return treeDataArray
  }
}


  // Populate Tree Array with Tree Data Array
//  var treeArray = [Tree]()
//  for treeData in treeDataArray {
//    if treeData[7] == "Living" {
//      let treeName = treeData[3]
//      let tree = Tree(title: treeName, detail: treeData, coordinate: CLLocationCoordinate2D(latitude: Double(treeData[1])!, longitude: Double(treeData[2])!))
//      treeArray.append(tree)
//    }
//  }
//  return treeArray
