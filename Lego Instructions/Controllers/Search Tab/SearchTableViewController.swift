//
//  SearchTableViewController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/4/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

//figure out why searching "small" crashes

class SearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var searchingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortButton: UIButton!
    
    var needsDataReload: Bool = false
    var resultsLegoSets: [LegoSet] = []
    var favoriteSetIDs: [String] = []
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
        tableView.layer.borderWidth = 2
        tableView.layer.borderColor = UIColor.black.cgColor
        
        loadingView.layer.borderWidth = 2
        loadingView.layer.borderColor = UIColor.black.cgColor
        
        view.bringSubviewToFront(loadingView)
        
        sortButton.titleLabel?.adjustsFontSizeToFitWidth = true
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if needsDataReload {
            tableView.reloadData()
            needsDataReload = false
        }
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
            "pageSize" : "50",
            "pageNumber" : "",
            "userName" : ""
        ]
        
        LegoSetsController.shared.fetchSets(queries: queries) { (legoSets) in
            DispatchQueue.main.async {
                self.resultsLegoSets = legoSets
                
                if legoSets.count > 0 {
                    self.loadingView.isHidden = true
                } else {
                    self.searchingIndicator.isHidden = true
                    self.activityLabel.text = "No Results Found\n\nCheck spelling or try being more specific"
                }
                
                self.sortSets()
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
            
        }
    }
    
    func sortSets() {
        guard resultsLegoSets.count != 0 else { return }
        
        switch currentSort {
        case .name:
            resultsLegoSets.sort(by: { $0.name < $1.name })
        case .year:
            resultsLegoSets.sort(by: { $0.year > $1.year })
        case .pieces:
            resultsLegoSets.sort(by: { $0.pieces > $1.pieces })
        case .theme:
            resultsLegoSets.sort(by: { $0.theme < $1.theme })
        case .id:
            resultsLegoSets.sort(by: { $0.id > $1.id })
        }
    }
    
    func changedSortOption(newSort: SortOption) {
        if newSort != currentSort {
            currentSort = newSort
            
            guard resultsLegoSets.count != 0 else { return }
            
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            sortSets()
            tableView.reloadData()
        }
    }
    
    //===========================================
    // MARK: - UITabBarControllerDelegate
    //===========================================
    
    //this function is called by all view controllers in the tab bar
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let toIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return false
        }
        
        tabBarController.animateToTab(toIndex: toIndex)
        return true
    }
    
    //===========================================
    // MARK: - Actions
    //===========================================
    
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
            if IVC.legoSet?.id != resultsLegoSets[sender.tag].id {
                IVC.legoSet = resultsLegoSets[sender.tag]
            }
            
            tabBar.animateToTab(toIndex: 1)
        }
        
    }
    
    @objc func favoriteButtonTapped(_ sender: UIButton) {
        
        if let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? SearchResultTableViewCell {
            let set = resultsLegoSets[sender.tag]
            cell.isFavorited = !cell.isFavorited
            
            if cell.isFavorited {
                cell.favoriteButton.setImage(UIImage(named: "favorited"), for: .normal)
            } else {
                cell.favoriteButton.setImage(UIImage(named: "unfavorited"), for: .normal)
            }
            
            if let viewControllers = tabBarController?.viewControllers,
                let FVC = viewControllers[2] as? FavoritesCollectionViewController {
                FVC.needsDataReload = true
            }
            
            FavoritesController.shared.changedFavoriteStatus(set: set)
            favoriteSetIDs = FavoritesController.shared.favoritesIds
        }
        
        
    }
    
    //========================================
    // MARK: - Table View Delegate
    //========================================

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteSetIDs = FavoritesController.shared.favoritesIds
        return resultsLegoSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "legoSetCell", for: indexPath) as! SearchResultTableViewCell
        let set = resultsLegoSets[indexPath.row]
        
        cell.instructionsButton.tag = indexPath.row
        cell.instructionsButton.addTarget(self, action: #selector(getInstructionsButtonTapped(_:)), for: .touchUpInside)
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        
        if favoriteSetIDs.contains(set.id) {
            cell.favoriteButton.setImage(UIImage(named: "favorited"), for: .normal)
            cell.isFavorited = true
        } else {
            cell.favoriteButton.setImage(UIImage(named: "unfavorited"), for: .normal)
            cell.isFavorited = false
        }
        
        cell.nameLabel.text = "\(set.name)  (\(set.year))"
        cell.themeLabel.text = set.theme
        cell.numberLabel.text = "ID: \(set.id)"
        cell.partsLabel.text = "Pieces: \(set.pieces)"
        cell.legoSetImageView.image = UIImage(named: "blankImage")
        cell.loadingIndicator.isHidden = false
        
        cellImage(for: set) { (image) in
            DispatchQueue.main.async {
                cell.legoSetImageView.image = image
                cell.loadingIndicator.isHidden = true
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
    
    //===========================================
    // MARK: - State Preservation
    //===========================================
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        if tabBarController?.selectedIndex != 0 {
            coder.encode(nil, forKey: "searchTerm")
        } else {
            coder.encode(searchBar.text, forKey: "searchTerm")
        }
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        guard tabBarController?.selectedIndex == 0 else { return }
        guard let searchText = coder.decodeObject(forKey: "searchTerm") as? String else { return }
        
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            searchBar.text = searchText
            search(searchTerm: searchText)
        }
        
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
