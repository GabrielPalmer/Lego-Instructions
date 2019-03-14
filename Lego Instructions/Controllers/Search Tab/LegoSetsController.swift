//
//  LegoSetsController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/4/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class LegoSetsController: NSObject, XMLParserDelegate {
    
    static let shared = LegoSetsController()
    let baseURL = URL(string: "https://brickset.com/api/v2.asmx/getSets")!
    
    var parsedSets: [LegoSet] = []
    
    fileprivate var currentElement: String = ""
    fileprivate var valueWasSet: Bool = false
    fileprivate var legoSetDict: Dictionary<String, String> = [
        "name" : "",
        "year" : "",
        "theme" : "",
        "partCount" : "",
        "id" : "",
        "imageURL" : "",
        "instructionsCount" : "",
        "rating" : ""
    ]
    
    func fetchSets(queries: Dictionary<String, String>, completion: @escaping ([LegoSet]) -> Void) {
        parsedSets.removeAll()
        let url = baseURL.withQueries(queries)!
        
        DispatchQueue.global(qos: .utility).async {
            let xmlParser = XMLParser(contentsOf: url)
            xmlParser?.delegate = self
            xmlParser?.parse()
            
            completion(self.parsedSets)
        }
        
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        valueWasSet = false
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "sets" && legoSetDict["instructionsCount"]! != "0" && legoSetDict["theme"]! != "Duplo" {
            if let legoSet = LegoSet(bricksetDictionary: legoSetDict) {
                parsedSets.append(legoSet)
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if !valueWasSet {
            valueWasSet = true
            
            switch currentElement {
            case "setID":
                legoSetDict["id"] = string
            case "name":
                legoSetDict["name"] = string
            case "year":
                legoSetDict["year"] = string
            case "theme":
                legoSetDict["theme"] = string
            case "pieces":
                legoSetDict["partCount"] = string
            case "imageURL":
                legoSetDict["imageURL"] = string
            case "instructionsCount":
                legoSetDict["instructionsCount"] = string
            case "rating":
                legoSetDict["rating"] = string
            default:
                break
            }
        }
        
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
}
