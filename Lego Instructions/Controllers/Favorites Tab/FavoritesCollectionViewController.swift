//
//  FavoritesCollectionViewController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/27/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class FavoritesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var needsDataReload: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsDataReload {
            collectionView.reloadData()
            needsDataReload = false
        }
    }
    
    @objc func instructionsButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc func removeButtonTapped(_ sender: UIButton) {
        
        if let viewControllers = tabBarController?.viewControllers,
            let SVC = viewControllers[0] as? SearchTableViewController {
            SVC.needsDataReload = true
        }
        
        FavoritesController.shared.changedFavoriteStatus(set: FavoritesController.shared.favoriteSets[sender.tag])
        
        collectionView.deleteItems(at: [IndexPath(item: sender.tag, section: 0)])
        
    }
    
    //========================================
    // MARK: - UICollectionViewDataSource
    //========================================

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FavoritesController.shared.favoriteSets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteCollectionViewCell
        let set = FavoritesController.shared.favoriteSets[indexPath.row]
        
        cell.idLabel.text = "#\(set.id)"
        cell.nameLabel.text = set.name
        
        cell.instructionsButton.tag = indexPath.row
        cell.removeButton.tag = indexPath.row
        
        cell.instructionsButton.addTarget(self, action: #selector(instructionsButtonTapped(_:)), for: .touchUpInside)
        cell.removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
        
        cell.layer.cornerRadius = 10
        
        cellImage(for: set) { (image) in
            DispatchQueue.main.async {
                cell.setImageView.image = image
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

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //===========================================
    // MARK: - FlowLayoutDelegate
    //===========================================
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalCells = Int(view.bounds.width / 400.0)
        let horizontalSpacing = (horizontalCells + 1) * 15
        let cellWidth = (view.bounds.width - CGFloat(horizontalSpacing)) / CGFloat(horizontalCells)
        
        return CGSize(width: cellWidth, height: 200)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 15, bottom: 25, right: 15)
    }

}
