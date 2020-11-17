//
//  SearchBarViewController.swift
//  TreeMapBCv2
//
//  Created by Allen Li on 11/16/20.
//  Copyright © 2020 Boston College. All rights reserved.
//

import UIKit
import CoreData

class SearchBarViewController: UIViewController {
  @IBOutlet var searchBarView: UIView!
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var selectionButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchTextField.delegate = self
  }
}

extension SearchBarViewController: UITextFieldDelegate {
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
