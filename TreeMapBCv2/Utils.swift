//
//  Utils.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 11/1/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import UIKit

extension UIColor {
  static let primaryColor = UIColor.init(red: 52/255, green: 69/255, blue: 63/255, alpha: 1)
  static let secondaryColor = UIColor.init(red: 147/255, green: 196/255, blue: 139/255, alpha: 1)
  static let highlightColor =  UIColor.init(red: 227/255, green: 101/255, blue: 91/255, alpha: 1)
}

extension CGColor {
  static let primaryColor = UIColor.primaryColor.cgColor
  static let secondaryColor = UIColor.secondaryColor.cgColor
  static let highlightColor =  UIColor.highlightColor.cgColor
}

extension Double {
  private static var addCommas: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    return numberFormatter
  }()
  
  internal var formatted: String {
    let roundedValue = NSNumber(value: self.rounded())
    return Double.addCommas.string(from: roundedValue) ?? ""
  }
}
