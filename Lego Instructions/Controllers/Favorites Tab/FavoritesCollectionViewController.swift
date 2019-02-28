//
//  FavoritesCollectionViewController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/27/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class FavoritesCollectionViewController: UICollectionViewController {
    
    var legoSets: [LegoSet] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        legoSets = FavoritesController.shared.favoriteSets
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if FavoritesController.shared.needsVisualUpdate {
            FavoritesController.shared.needsVisualUpdate = false
            collectionView.reloadData()
        }
    }
    
    //========================================
    // MARK: - UICollectionViewDataSource
    //========================================

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FavoritesController.shared.favoriteSets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath)
    
    
        return cell
    }

    //========================================
    // MARK: - UICollectionViewDelegate
    //========================================

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

}
