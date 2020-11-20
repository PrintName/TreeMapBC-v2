//
//  PassthroughView.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 11/20/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import UIKit

class PassthroughView: UIView {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    return hitView == self ? nil : hitView
  }
}
