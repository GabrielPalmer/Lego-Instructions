//
//  SearchTableViewController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/4/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class SearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var searchingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortButton: UIButton!
    
    var legoSets: [LegoSet] = []
    var currentSort: SortOption = .name
    
    enum SortOption {
        case name
        case year
        case pieces
        case theme
        case id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.bringSubviewToFront(loadingView)
        
        sortButton.titleLabel?.adjustsFontSizeToFitWidth = true
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    func search(searchTerm: String) {
        
        let queries: Dictionary<String, String> = [
            "apiKey" : "B5sG-5uAN-22mW",
            "query" : searchTerm,
            
            "orderBy" : "",
            "userHash" : "",
            "year" : "",
            "theme" : "",
            "subtheme" : "",
            "setNumber" : "",
            "owned" : "",
            "wanted" : "",
            "pageSize" : "30",
            "pageNumber" : "",
            "userName" : ""
        ]
        
        LegoSetsController.shared.fetchSets(queries: queries) { (legoSets) in
            DispatchQueue.main.async {
                self.legoSets = legoSets
                
                if legoSets.count > 0 {
                    self.loadingView.isHidden = true
                } else {
                    self.searchingIndicator.isHidden = true
                    self.activityLabel.text = "No Results Found\n\nCheck spelling or try being more specific"
                }
                
                self.sortSets()
                self.tableView.reloadData()
            }
            
        }
    }
    
    func sortSets() {
        guard legoSets.count != 0 else { return }
        
        switch currentSort {
        case .name:
            legoSets.sort(by: { $0.name < $1.name })
        case .year:
            legoSets.sort(by: { $0.year > $1.year })
        case .pieces:
            legoSets.sort(by: { $0.pieces > $1.pieces })
        case .theme:
            legoSets.sort(by: { $0.theme < $1.theme })
        case .id:
            legoSets.sort(by: { $0.id > $1.id })
        }
    }
    
    func changedSortOption(newSort: SortOption) {
        if newSort != currentSort {
            currentSort = newSort
            
            guard legoSets.count != 0 else { return }
            
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            sortSets()
            tableView.reloadData()
        }
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
            handler: { (_) in
                self.sortButton.setTitle("Name", for: .normal)
                self.changedSortOption(newSort: .name)
        }))
        
        alertController.addAction(UIAlertAction(
            title: "Year",
            style: .default,
            handler: { (_) in
                self.sortButton.setTitle("Year", for: .normal)
                self.changedSortOption(newSort: .year)
        }))
        
        alertController.addAction(UIAlertAction(
            title: "Pieces",
            style: .default,
            handler: { (_) in
                self.sortButton.setTitle("Pieces", for: .normal)
                self.changedSortOption(newSort: .pieces)
        }))
        
        alertController.addAction(UIAlertAction(
            title: "Theme",
            style: .default,
            handler: { (_) in
                self.sortButton.setTitle("Theme", for: .normal)
                self.changedSortOption(newSort: .pieces)
        }))
        
        alertController.addAction(UIAlertAction(
            title: "Set Number",
            style: .default,
            handler: { (_) in
                self.sortButton.setTitle("Set ID", for: .normal)
                self.changedSortOption(newSort: .id)
        }))

        present(alertController, animated: true)
        
        let sourceRect = CGRect(x: sortButton.bounds.width / 2, y: sortButton.bounds.height, width: 0, height: 0)
        alertController.popoverPresentationController?.sourceView = sortButton
        alertController.popoverPresentationController?.sourceRect = sourceRect
        
    }
    
    @objc func getInstructionsButtonTapped(_ sender: UIButton) {
        if let tabBar = tabBarController,
            let viewControllers = tabBarController?.viewControllers,
            let IVC = viewControllers[1] as? InstructionsViewController {
            
            IVC.loadViewIfNeeded()
            
            //stops same pdf from being loaded again
            if IVC.legoSet?.id != legoSets[sender.tag].id {
                IVC.legoSet = legoSets[sender.tag]
            }
            
            tabBar.selectedIndex = 1
        }
        
    }
    
    //========================================
    // MARK: - Table View Delegate
    //========================================

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legoSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "legoSetCell", for: indexPath) as! SearchResultTableViewCell
        let set = legoSets[indexPath.row]
        
        cell.instructionsButton.tag = indexPath.row
        cell.instructionsButton.addTarget(self, action: #selector(getInstructionsButtonTapped(_:)), for: .touchUpInside)
        
        cell.nameLabel.text = "\(set.name)  (\(set.year))"
        cell.themeLabel.text = set.theme
        cell.numberLabel.text = "ID: \(set.id)"
        cell.partsLabel.text = "Pieces: \(set.pieces)"
        
        cellImage(for: set) { (image) in
            DispatchQueue.main.async {
                cell.legoSetImageView.image = image
            }
        }
        
        return cell
    }
    
    func cellImage(for item: LegoSet, completion: @escaping (UIImage?) -> Void) {
        
        URLSession.shared.dataTask(with: URL(string: item.imageURL)!) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                print("Failed to retrieve image")
                completion(UIImage(named: "imageError"))
            }
            }.resume()
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
}

//========================================
// MARK: - Search Bar Delegate
//========================================

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else { return }
        
        searchingIndicator.isHidden = false
        activityLabel.text = "Searching"
        
        loadingView.isHidden = false
        
        search(searchTerm: searchTerm)
    }
}

//========================================
// MARK: - Text Field Delegate
//========================================

//extension SearchTableViewController: UITextFieldDelegate {
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        if !string.isEmpty && (textField.text ?? "").count > 3 && Int((textField.text ?? "")) == nil {
//            return false
//        }
//
//        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
//        return string.rangeOfCharacter(from: invalidCharacters) == nil
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        search()
//        return true
//    }
//}
