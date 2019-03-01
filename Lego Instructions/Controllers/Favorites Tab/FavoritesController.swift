//
//  FavoritesController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/27/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class FavoritesController {
    static let shared = FavoritesController()
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let setsArchiveURL = documentsDirectory.appendingPathComponent("favorites").appendingPathExtension("plist")
    
    var favoriteSets: [LegoSet] = []
    var favoritesIds: [String] {
        var ids: [String] = []
        for set in favoriteSets {
            ids.append(set.id)
        }
        return ids
    }
    
    func loadFavorites() {
        
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedSetsData = try? Data(contentsOf: FavoritesController.setsArchiveURL),
            let decodedSets = try? propertyListDecoder.decode(Array<LegoSet>.self, from: retrievedSetsData) {
            
            favoriteSets = decodedSets
        } else {
            print("Could not load favorites data")
        }
    }
    
    func changedFavoriteStatus(set: LegoSet) {
        
        if favoritesIds.contains(set.id) {
            for index in 0...favoriteSets.count - 1 {
                if favoriteSets[index].id == set.id {
                    favoriteSets.remove(at: index)
                    break
                }
            }
        } else {
            favoriteSets.insert(set, at: 0)
        }
        
        do {
            let propertyListEncoder = PropertyListEncoder()
            let encodedSets = try propertyListEncoder.encode(favoriteSets)
            try encodedSets.write(to: FavoritesController.setsArchiveURL, options: .noFileProtection)
            print("updated favorites")
        } catch {
            print("failed to save favorites")
            print(error)
        }
        
        
    }
    
    
    
    
}
