//
//  TreeAnnotation.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 10/29/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import Foundation
import MapKit

class TreeAnnotation: NSObject, MKAnnotation {
  let title: String?
  let subtitle: String?
  let tag: Int
  let coordinate: CLLocationCoordinate2D
  let commonName: String
  let botanicalName: String
  let campus: String
  let dbh: Double
  let carbonOffset: Double
  let distanceDriven: Double
  let carbonStorage: Double
  let pollutionRemoved: Double
  let waterIntercepted: Double
  
  init(title: String?, subtitle: String?, tag: Int, coordinate: CLLocationCoordinate2D, commonName: String, botanicalName: String, campus: String, dbh: Double, carbonOffset: Double, distanceDriven: Double, carbonStorage: Double, pollutionRemoved: Double, waterIntercepted: Double) {
    self.title = title
    self.subtitle = subtitle
    self.tag = tag
    self.coordinate = coordinate
    self.commonName = commonName
    self.botanicalName = botanicalName
    self.campus = campus
    self.dbh = dbh
    self.carbonOffset = carbonOffset
    self.distanceDriven = distanceDriven
    self.carbonStorage = carbonStorage
    self.pollutionRemoved = pollutionRemoved
    self.waterIntercepted = waterIntercepted
    super.init()
  }
}
