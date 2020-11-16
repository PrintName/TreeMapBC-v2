//
//  TreeAnnotationView.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 10/30/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import Foundation
import MapKit

class TreeAnnotationView: MKAnnotationView {
  let diameter = 36
  
  let glyphImageView: UIImageView = {
    let glyphImage = UIImage(named: "treeGlyph")!
    let imageView = UIImageView(frame: CGRect(x: 8, y: 8, width: 20, height: 20))
    imageView.image = glyphImage
    imageView.tintColor = .secondaryColor
    return imageView
  }()
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    
    addSubview(glyphImageView)
    collisionMode = .circle
    frame.size = CGSize(width: diameter, height: diameter)
    layer.cornerRadius = frame.width / 2
    layer.masksToBounds = true
    layer.borderColor = .secondaryColor
    layer.backgroundColor = .primaryColor
    layer.borderWidth = 1.5
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var annotation: MKAnnotation? {
    willSet {
      if newValue is TreeAnnotation {
        self.displayPriority = .required
      }
    }
  }
}
