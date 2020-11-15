//
//  TreeAnnotationView.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 10/30/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import Foundation
import MapKit

class TreeAnnotationView: MKMarkerAnnotationView {
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    collisionMode = .circle
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForDisplay() {
    super.prepareForDisplay()
    markerTintColor = .primaryColor
    glyphImage = UIImage(named: "treeGlyph")
    glyphTintColor = .secondaryColor
  }
  
  override var annotation: MKAnnotation? {
    willSet {
      if newValue is TreeAnnotation {
        self.displayPriority = .required
      }
    }
  }
}
