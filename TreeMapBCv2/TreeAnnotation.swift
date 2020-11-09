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
  let impact: Impact
  
  struct Impact {
    var carbonOffset: Double = 0
    var distanceDriven: Double = 0
    var carbonStorage: Double = 0
    var pollutionRemoved: Double = 0
    var waterIntercepted: Double = 0
  }
  
  init(title: String?, subtitle: String?, tag: Int, coordinate: CLLocationCoordinate2D, commonName: String, botanicalName: String, campus: String, dbh: Double, impact: Impact) {
    self.title = title
    self.subtitle = subtitle
    self.tag = tag
    self.coordinate = coordinate
    self.commonName = commonName
    self.botanicalName = botanicalName
    self.campus = campus
    self.dbh = dbh
    self.impact = impact
    super.init()
  }
}
