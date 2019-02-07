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
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var partsLabel: UILabel!
    
    func setUpCell(legoSet: LegoSet) {
        nameLabel.text = "\(legoSet.name) (\(legoSet.year))"
        numberLabel.text = legoSet.id
        partsLabel.text = "\(legoSet.partCount) Pieces"
    }

}
