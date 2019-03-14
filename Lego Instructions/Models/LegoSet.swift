//
//  LegoSet.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/4/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class LegoSet: NSObject, NSCoding, Codable {
    
    let name: String
    let year: Int
    let theme: String
    let pieces: Int
    let id: String
    let imageURL: String
    var instructionsCount: String
    
    init?(bricksetDictionary dict: [String : String]) {
        self.name = dict["name"]!
        guard let year = Int(dict["year"]!) else { return nil }
        self.year = year
        self.theme = dict["theme"]!
        guard let pieces = Int(dict["partCount"]!) else { return nil }
        self.pieces = pieces
        self.id = dict["id"]!
        self.imageURL = dict["imageURL"]!
        self.instructionsCount = dict["instructionsCount"]!
        
    }
    
    init?(rebrickableDictionary dict: Dictionary<String, Any>) {
        guard let name = dict["name"] as? String,
            let year = dict["year"] as? Int,
            let id = dict["set_num"] as? String,
            let pieces = dict["num_parts"] as? Int else { return nil }
        
        self.name = name
        self.year = year
        self.id = id
        self.pieces = pieces
        
        theme = "no theme"
        imageURL = "no image"
        instructionsCount = "no instructions"
        
    }
    
    init(name: String, year: Int, theme: String, pieces: Int, id: String, imageURL: String, instructionsCount: String) {
        self.name = name
        self.year = year
        self.theme = theme
        self.pieces = pieces
        self.id = id
        self.imageURL = imageURL
        self.instructionsCount = instructionsCount
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.year, forKey: "year")
        aCoder.encode(self.theme, forKey: "theme")
        aCoder.encode(self.pieces, forKey: "pieces")
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.imageURL, forKey: "imageURL")
        aCoder.encode(self.instructionsCount, forKey: "instructionsCount")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String,
            let theme = aDecoder.decodeObject(forKey: "theme") as? String,
            let id = aDecoder.decodeObject(forKey: "id") as? String,
            let imageURL = aDecoder.decodeObject(forKey: "imageURL") as? String,
            let instructionsCount = aDecoder.decodeObject(forKey: "instructionsCount") as? String else { return nil }
        
        //if key not found, uses type's default value
        let year = aDecoder.decodeInteger(forKey: "year")
        let pieces = aDecoder.decodeInteger(forKey: "pieces")
        
        self.init(name: name, year: year, theme: theme, pieces: pieces, id: id, imageURL: imageURL, instructionsCount: instructionsCount)
        
    }
    
}
