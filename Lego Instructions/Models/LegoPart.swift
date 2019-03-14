//
//  LegoPart.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 3/12/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class LegoPart {
    let name: String
    let imageURL: String
    let quantity: Int
    
    init?(dict: Dictionary<String, Any>) {
        guard dict["is_spare"] as? Bool == false,
            let quantity = dict["quantity"] as? Int,
            let partInfo = dict["part"] as? Dictionary<String, Any>,
            let imageURL = partInfo["part_img_url"] as? String,
            let name = partInfo["name"] as? String else { return nil }
        
        self.name = name
        self.imageURL = imageURL
        self.quantity = quantity
    }
}
