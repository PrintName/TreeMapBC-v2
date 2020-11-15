//
//  TreeClusterAnnotationView.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 10/30/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import Foundation
import MapKit
import Cluster

class TreeClusterAnnotationView: ClusterAnnotationView {
  override func configure() {
    super.configure()
    
    guard let annotation = annotation as? ClusterAnnotation else { return }
    let count = annotation.annotations.count
    let diameter = radius(for: count) * 2
    frame.size = CGSize(width: diameter, height: diameter)
    layer.cornerRadius = frame.width / 2
    layer.masksToBounds = true
    layer.borderColor = UIColor.white.cgColor
    layer.backgroundColor = .primaryColor
    layer.borderWidth = 1.5
  }
  
  func radius(for count: Int) -> CGFloat {
    if count < 5 {
      return 16
    } else if count < 10 {
      return 18
    } else {
      return 20
    }
  }
}
