//
//  LegoSet.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/4/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class LegoSet: Codable {
    let name: String
    let year: Int
    let theme: String
    let pieces: Int
    let id: String
    let imageURL: String
    var instructionsCount: String
    
    init?(_ legoSetDict: [String : String]) {
        self.name = legoSetDict["name"]!
        guard let year = Int(legoSetDict["year"]!) else { return nil }
        self.year = year
        self.theme = legoSetDict["theme"]!
        guard let pieces = Int(legoSetDict["partCount"]!) else { return nil }
        self.pieces = pieces
        self.id = legoSetDict["id"]!
        self.imageURL = legoSetDict["imageURL"]!
        self.instructionsCount = legoSetDict["instructionsCount"]!
    }
}
