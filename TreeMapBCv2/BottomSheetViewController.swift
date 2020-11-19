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
  
  @IBOutlet weak var impactLabelButton: UIButton!
  @IBOutlet weak var impactArrowButton: UIButton!
  
  @IBOutlet weak var bottomSheetImpact: UILabel!
  
  let screenHeight: CGFloat = UIScreen.main.bounds.height
  let fullViewSpacing: CGFloat = UIScreen.main.bounds.height - 375
  let partialViewSpacing: CGFloat = UIScreen.main.bounds.height - 165
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureBottonSheetView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    animateShow()
  }
  
  func animateShow() {
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self = self else { return }
      let frame = self.view.frame
      self.view.frame = .init(x: 0, y: self.partialViewSpacing, width: frame.width, height: frame.height)
    })
  }
  
  func animateHide() {
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self = self else { return }
      let frame = self.view.frame
      self.view.frame = .init(x: 0, y: self.screenHeight, width: frame.width, height: frame.height)
    })
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
  
  @IBAction func impactButtonsTouched(_ sender: Any) {
    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction], animations: {
      self.showFullDetail()
    }, completion: nil)
  }
  
  @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
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
      duration = duration > 0.6 ? 0.5 : duration
      
      UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
        if velocity.y >= 0 {
          self.hideFullDetail()
        } else {
          self.showFullDetail()
        }
      }, completion: nil)
    }
  }
  
  func showFullDetail() {
    self.view.frame = CGRect(x: 0, y: fullViewSpacing, width: self.view.frame.width, height: self.view.frame.height)
    self.bottomSheetDetail.numberOfLines = 0
    self.impactLabelButton.isHidden = true
    self.impactArrowButton.isHidden = true
    self.bottomSheetDetailRightConstraint.constant = 40
  }
  
  func hideFullDetail() {
    self.view.frame = CGRect(x: 0, y: partialViewSpacing, width: self.view.frame.width, height: self.view.frame.height)
    self.bottomSheetDetail.numberOfLines = 4
    self.impactLabelButton.isHidden = false
    self.impactArrowButton.isHidden = false
    self.bottomSheetDetailRightConstraint.constant = 100
  }
}
