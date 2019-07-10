//
//  FavoritesCollectionViewController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/27/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class FavoritesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var favoriteSets: [LegoSet] = []
    var needsDataReload: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsDataReload {
            collectionView.reloadData()
            needsDataReload = false
        }
    }
    
    @objc func instructionsButtonTapped(_ sender: UIButton) {
        if let tabBar = tabBarController,
            let viewControllers = tabBarController?.viewControllers,
            let IVC = viewControllers[1] as? InstructionsViewController {
            
            IVC.loadViewIfNeeded()
            
            //stops same pdf from being loaded again
            if IVC.legoSet?.id != favoriteSets[sender.tag].id {
                IVC.legoSet = favoriteSets[sender.tag]
            }
            
            tabBar.animateToTab(toIndex: 1)
        }
    }
    
    @objc func removeButtonTapped(_ sender: UIButton) {
        
        let alertController = UIAlertController(
            title: "Remove \"\(favoriteSets[sender.tag].name)\"\nfrom your favorites?",
            message: nil,
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { (_) in
                
                if let viewControllers = self.tabBarController?.viewControllers,
                    let SVC = viewControllers[0] as? SearchTableViewController {
                    SVC.needsDataReload = true
                }
                
                FavoritesController.shared.changedFavoriteStatus(set: self.favoriteSets[sender.tag])
                self.favoriteSets.remove(at: sender.tag)
                self.collectionView.deleteItems(at: [IndexPath(item: sender.tag, section: 0)])
                
                for cell in self.collectionView.visibleCells as! [FavoriteCollectionViewCell] {
                    if cell.instructionsButton.tag > sender.tag {
                        cell.instructionsButton.tag -= 1
                        cell.removeButton.tag -= 1
                    }
                }
                
        }))
        
        present(alertController, animated: true)
        alertController.popoverPresentationController?.permittedArrowDirections = .up
        let sourceRect = CGRect(x: sender.bounds.width / 2, y: sender.bounds.height, width: 0, height: 0)
        alertController.popoverPresentationController?.sourceView = sender
        alertController.popoverPresentationController?.sourceRect = sourceRect

    }
    
    //========================================
    // MARK: - UICollectionViewDataSource
    //========================================

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        favoriteSets = FavoritesController.shared.favoriteSets
        return favoriteSets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteCollectionViewCell
        let set = favoriteSets[indexPath.row]

        cell.idLabel.text = "#\(set.id)"
        cell.nameLabel.text = set.name
        cell.instructionsButton.tag = indexPath.row
        cell.removeButton.tag = indexPath.row
        cell.instructionsButton.addTarget(self, action: #selector(instructionsButtonTapped(_:)), for: .touchUpInside)
        cell.removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
        cell.layer.cornerRadius = 10
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.setImageView.image = UIImage(named: "blankImage")
        cell.loadingIndicator.isHidden = false
        
        cellImage(for: set) { (image) in
            DispatchQueue.main.async {
                cell.setImageView.image = image
                cell.loadingIndicator.isHidden = true
            }
        }
        
        return cell
    }
    
    func cellImage(for item: LegoSet, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: item.imageURL) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(UIImage(named: "imageError"))
                }
                }.resume()
        } else {
            completion(UIImage(named: "imageError"))
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //===========================================
    // MARK: - FlowLayoutDelegate
    //===========================================
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var horizontalCells = Int(view.bounds.width / 350.0)
        
        if horizontalCells < 2 {
            horizontalCells = 2
        }
        
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
