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
  @IBOutlet weak var searchBarView: UIView!
  @IBOutlet weak var searchBarViewHeight: NSLayoutConstraint!
  @IBOutlet weak var searchFieldView: UIView!
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var campusSegmentedControl: UISegmentedControl!
  @IBOutlet weak var searchResultTableView: UITableView!
  
  var searchFieldViewShadow: UIView!
  
  var speciesArray = [Species]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchTextField.delegate = self
    let clearImage = UIImage(color: .clear)
    campusSegmentedControl.setBackgroundImage(clearImage, for: .normal, barMetrics: .default)
    campusSegmentedControl.setBackgroundImage(clearImage, for: .selected, barMetrics: .default)
    campusSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.highlightColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)], for: .selected)
    campusSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.highlightColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)], for: .highlighted)
    
    searchFieldViewShadow = UIView(frame: searchFieldView.frame)
    searchView.addSubview(searchFieldViewShadow)
    searchView.sendSubviewToBack(searchFieldViewShadow)
    searchFieldViewShadow.layer.shadowColor = UIColor.black.cgColor
    searchFieldViewShadow.layer.shadowOpacity = 0.5
    searchFieldViewShadow.layer.shadowOffset = .zero
    searchFieldViewShadow.layer.shadowRadius = 4
    searchFieldViewShadow.layer.shadowPath = UIBezierPath(rect: searchFieldViewShadow.bounds).cgPath
    
    searchFieldView.layer.shadowColor = UIColor.black.cgColor
    searchFieldView.layer.shadowOpacity = 0.5
    searchFieldView.layer.shadowOffset = .zero
    searchFieldView.layer.shadowRadius = 4
    searchFieldView.layer.shadowPath = UIBezierPath(rect: searchFieldView.bounds).cgPath
    searchBarView.layer.masksToBounds = true
    searchBarView.layer.cornerRadius = 5
    searchBarViewHeight.constant = 42
    
    searchResultTableView.layer.masksToBounds = true
    searchResultTableView.layer.cornerRadius = 5
    searchResultTableView.delegate = self
    searchResultTableView.dataSource = self
    
    searchResultTableView.alpha = 0
    searchResultTableView.isHidden = true
  }
  
  @IBAction func cancelButtonTouched(_ sender: Any) {
    searchTextField.text = ""
    searchTextField.resignFirstResponder()
  }
}

extension SearchViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    fadeSearchFieldViewShadow()
    searchResultTableView.isUserInteractionEnabled = true
    showSearchResultTableView()
    showCampusSegmentedControl()
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    showSearchFieldViewShadow()
    searchResultTableView.isUserInteractionEnabled = false
    hideSearchResultTableView()
    hideCampusSegmentedControl()
  }
  
  private func showSearchResultTableView() {
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self = self else { return }
      self.searchResultTableView.isHidden = false
      self.searchResultTableView.alpha = 1
      self.view.layoutIfNeeded()
    })
  }
  
  private func hideSearchResultTableView() {
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self = self else { return }
      self.searchResultTableView.alpha = 0
      self.view.layoutIfNeeded()
    }, completion: { _ in
      self.searchResultTableView.isHidden = true
    })
  }
  
  private func showCampusSegmentedControl() {
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self = self else { return }
      self.searchBarViewHeight.constant = 80
      self.view.layoutIfNeeded()
    })
  }
  
  private func hideCampusSegmentedControl() {
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self = self else { return }
      self.searchBarViewHeight.constant = 42
      self.view.layoutIfNeeded()
    })
  }
  
  private func showSearchFieldViewShadow() {
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self = self else { return }
      self.searchFieldViewShadow.layer.shadowOpacity = 0.5
    })
  }
  
  private func fadeSearchFieldViewShadow() {
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self = self else { return }
      self.searchFieldViewShadow.layer.shadowOpacity = 0
    })
  }
  
  func textFieldDidChangeSelection(_ textField: UITextField) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Species")
    fetchRequest.predicate = NSPredicate(format: "commonName CONTAINS '\(textField.text?.capitalized ?? "")'")
    do {
      if let species = try managedObjectContext.fetch(fetchRequest) as? [Species] {
        speciesArray = species
        searchResultTableView.reloadData()
      }
    } catch {}
  }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return speciesArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SpeciesCell", for: indexPath)
    let species = speciesArray[indexPath.row]
    cell.textLabel?.text = species.commonName
    cell.detailTextLabel?.text = species.botanicalName
    return cell
  }
}