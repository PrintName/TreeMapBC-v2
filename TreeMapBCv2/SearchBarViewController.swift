//
//  SearchViewController.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 11/16/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {
  @IBOutlet var searchView: UIView!
  @IBOutlet weak var searchFieldView: UIView!
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var campusSegmentedControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchTextField.delegate = self
    let clearImage = UIImage(color: .clear)
    campusSegmentedControl.setBackgroundImage(clearImage, for: .normal, barMetrics: .default)
    campusSegmentedControl.setBackgroundImage(clearImage, for: .selected, barMetrics: .default)
    campusSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.highlightColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)], for: .selected)
    campusSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.highlightColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)], for: .highlighted)

    searchFieldView.layer.shadowColor = UIColor.black.cgColor
    searchFieldView.layer.shadowOpacity = 0.5
    searchFieldView.layer.shadowOffset = .zero
    searchFieldView.layer.shadowRadius = 4
    searchFieldView.layer.shadowPath = UIBezierPath(rect: searchFieldView.bounds).cgPath
    searchView.layer.masksToBounds = true
    searchView.layer.cornerRadius = 5
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
  }
  
  @objc func keyboardWillShow(_ notification: NSNotification) {
    let info = notification.userInfo!
    let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    print(keyboardFrame.height)
  }
}

extension SearchViewController: UITextFieldDelegate {
  func textFieldDidChangeSelection(_ textField: UITextField) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Species")
    fetchRequest.predicate = NSPredicate(format: "commonName CONTAINS '\(textField.text?.capitalized ?? "")'")
    do {
      if let speciesObjects = try managedObjectContext.fetch(fetchRequest) as? [Species] {
        for species in speciesObjects {
          print(species.commonName)
        }
      }
    } catch {}
  }
}
