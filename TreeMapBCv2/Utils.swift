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

extension UIImage {
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
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
