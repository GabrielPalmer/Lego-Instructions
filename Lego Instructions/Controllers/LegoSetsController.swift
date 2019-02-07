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
    
    var loadedSets: [LegoSet] = []
    
    fileprivate var currentElement: String = ""
    fileprivate var legoSetDict: Dictionary<String, String> = [
        "name" : "",
        "year" : "",
        "partCount" : "",
        "id" : "",
        "imageURL" : ""
    ]
    
    func fetchSets(queries: Dictionary<String, String>) {
        loadedSets.removeAll()
        //let parseGroup = DispatchGroup()
        let url = baseURL.withQueries(queries)!
        
        let xmlParser = XMLParser(contentsOf: url)
        xmlParser?.delegate = self
        xmlParser?.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "sets" {
           
        }
        
    }
    
    

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(string)
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
}
