//
//  BottomSheetViewController.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 11/6/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import UIKit

class BottomSheetViewController: UIViewController {
  @IBOutlet var bottomSheetView: UIView!
  
  @IBOutlet weak var bottomSheetTitle: UILabel!
  @IBOutlet weak var bottomSheetSubtitle: UILabel!
  
  @IBOutlet weak var bottomSheetDetail: UILabel!
  @IBOutlet weak var bottomSheetDetailRightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var impactLabel: UILabel!
  @IBOutlet weak var impactArrow: UIImageView!
  
  @IBOutlet weak var bottomSheetImpact: UILabel!
  
  let fullViewHeight: CGFloat = 500
  let partialViewHeight: CGFloat = 165
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureBottonSheetView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    UIView.animate(withDuration: 0.3) { [weak self] in
      let frame = self?.view.frame
      let yComponent = UIScreen.main.bounds.height - self!.partialViewHeight
      self!.view.frame = .init(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
    }
  }
  
  func configureBottonSheetView() {
    Bundle.main.loadNibNamed("BottomSheet", owner: self, options: nil)
    
    let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetViewController.panGesture))
    view.addGestureRecognizer(gesture)
    
    bottomSheetView.layer.shadowColor = UIColor.black.cgColor
    bottomSheetView.layer.shadowOpacity = 0.5
    bottomSheetView.layer.shadowOffset = .zero
    bottomSheetView.layer.shadowRadius = 10
    bottomSheetView.layer.shadowPath = UIBezierPath(rect: bottomSheetView.bounds).cgPath
  }
  
  @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
    let fullViewSpacing: CGFloat = UIScreen.main.bounds.height - fullViewHeight
    let partialViewSpacing: CGFloat = UIScreen.main.bounds.height - partialViewHeight
    
    let translation = recognizer.translation(in: self.view)
    let velocity = recognizer.velocity(in: self.view)
    
    let minY = self.view.frame.minY
    let currentY = minY + translation.y

    // Currently panning
    if (currentY >= fullViewSpacing) && (currentY <= partialViewSpacing) {
      self.view.frame = CGRect(x: 0, y: currentY, width: view.frame.width, height: view.frame.height)
      recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    // Done panning
    if recognizer.state == .ended {
      var duration = velocity.y < 0 ? Double((minY - fullViewSpacing) / -velocity.y) : Double((partialViewSpacing - minY) / velocity.y)
      duration = duration > 1.3 ? 1 : duration
      
      UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
        if velocity.y >= 0 {
          self.view.frame = CGRect(x: 0, y: partialViewSpacing, width: self.view.frame.width, height: self.view.frame.height)
          self.displayFullDetail(false)
        } else {
          self.view.frame = CGRect(x: 0, y: fullViewSpacing, width: self.view.frame.width, height: self.view.frame.height)
          self.displayFullDetail(true)
        }
      }, completion: nil)
    }
  }
  
  func displayFullDetail(_ full: Bool) {
    switch full {
    case false:
      self.bottomSheetDetail.numberOfLines = 4
      self.impactLabel.isHidden = false
      self.impactArrow.isHidden = false
      self.bottomSheetDetailRightConstraint.constant = 100
    case true:
      self.bottomSheetDetail.numberOfLines = 0
      self.impactLabel.isHidden = true
      self.impactArrow.isHidden = true
      self.bottomSheetDetailRightConstraint.constant = 40
    }
  }
}
