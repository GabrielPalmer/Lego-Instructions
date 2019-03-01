//
//  SearchResultTableViewCell.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/4/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var legoSetImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var partsLabel: UILabel!
    @IBOutlet weak var instructionsButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    //this mostly exists so reloading the table is faster because it doesn't loop through favoriteIds
    var isFavorited: Bool = false
    
}
