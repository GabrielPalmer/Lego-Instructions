//
//  PartTableViewCell.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 3/14/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class PartTableViewCell: UITableViewCell {

    @IBOutlet weak var partImageView: UIImageView!
    @IBOutlet weak var quantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bringSubviewToFront(quantityLabel)
    }

}
