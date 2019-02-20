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
    let theme: String
    let partCount: String
    let id: String
    let imageURL: String
    let rating: String
    let instructionsCount: String
    
    init(_ legoSetDict: [String : String]) {
        self.name = legoSetDict["name"]!
        self.year = legoSetDict["year"]!
        self.theme = legoSetDict["theme"]!
        self.partCount = legoSetDict["partCount"]!
        self.id = legoSetDict["id"]!
        self.imageURL = legoSetDict["imageURL"]!
        self.rating = legoSetDict["rating"]!
        self.instructionsCount = legoSetDict["instructionsCount"]!
    }
}
