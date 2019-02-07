//
//  SearchTableViewController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/4/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class SearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var sortButton: UIButton!
    
    var legoSets: [LegoSet] = []
    
    /*
     sortBy options
     
     Number
     Pieces
     Rating
     Name
     Theme
    */
    
    //ignore set with zero instructions
    //ignore non-released sets
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        yearTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    //========================================
    // MARK: - Actions
    //========================================
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        
        let alertController = UIAlertController(
            title: "Sort By",
            message: nil,
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
            title: "Name",
            style: .default,
            handler: nil))
        
        alertController.addAction(UIAlertAction(
            title: "Set Number",
            style: .default,
            handler: nil))
        
        alertController.addAction(UIAlertAction(
            title: "Rating",
            style: .default,
            handler: nil))
        
        alertController.addAction(UIAlertAction(
            title: "Pieces",
            style: .default,
            handler: nil))

        
        present(alertController, animated: true)
        
        //alertController.popoverPresentationController?.popoverLayoutMargins = view.layoutMargins
        alertController.popoverPresentationController?.sourceView = sortButton
    }
    
    //========================================
    // MARK: - Table View Delegate
    //========================================

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
        //return legoSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "legoSetCell", for: indexPath) as! SearchResultTableViewCell
        
        //if year is empty, add it to the name
        
        return cell
    }
    
}

//========================================
// MARK: - Search Bar Delegate
//========================================

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text, let yearString = yearTextField.text, !searchTerm.isEmpty else { return }
        
        var queries: Dictionary<String, String> = [
            "apiKey" : "B5sG-5uAN-22mW",
            "query" : searchTerm,
            
            "orderBy" : "",
            "userHash" : "",
            "theme" : "",
            "subtheme" : "",
            "setNumber" : "",
            "owned" : "",
            "wanted" : "",
            "pageSize" : "",
            "pageNumber" : "",
            "userName" : ""
        ]
        
        //https://brickset.com/api/v2.asmx/getSets?apiKey=sG-5uAN-22mW&userHash=g&query=harry%20potter&theme=&subtheme=&setNumber=&year=&owned=&wanted=&orderBy=&pageSize=&pageNumber=&userName=
        
        if let yearInt = Int(yearString),
            yearInt >= 1954 && yearInt <= 2019,
            !yearString.isEmpty {
            
            queries["year"] = yearString
        } else {
            queries["year"] = ""
        }
        
        LegoSetsController.shared.fetchSets(queries: queries)
    }
}

//========================================
// MARK: - Text Field Delegate
//========================================

extension SearchTableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !string.isEmpty && (textField.text ?? "").count > 3 && Int((textField.text ?? "")) == nil {
            return false
        }
        
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
