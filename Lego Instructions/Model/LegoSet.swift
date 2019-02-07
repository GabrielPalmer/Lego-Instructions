//
//  LegoSet.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/4/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class LegoSet {
    let name: String
    let year: String
    let partCount: String
    let id: String
    let imageURL: String
    
    init(attributeDict: [String : String]) {
        name = "bob the builder"
        year = "1990"
        partCount = "666"
        id = "12345"
        imageURL = "blarrrrrg"
    }
}
