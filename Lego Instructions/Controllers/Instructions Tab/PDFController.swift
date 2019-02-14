//
//  PDFController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/11/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation
import PDFKit

class PDFController: NSObject, XMLParserDelegate {
    static let shared = PDFController()
    let baseURL = "https://brickset.com/api/v2.asmx/getInstructions?apiKey=B5sG-5uAN-22mW&setID="
    
    fileprivate var instructionsURLs: [String] = []
    fileprivate var currentElement: String = ""
    fileprivate var valueWasSet: Bool = false
    
    func fetchInstructionURLs(for legoSet: LegoSet, completion: @escaping ([String]) -> Void) {
        instructionsURLs.removeAll()
        
        DispatchQueue.global(qos: .utility).async {
            let xmlParser = XMLParser(contentsOf: URL(string: self.baseURL + legoSet.id)!)
            xmlParser?.delegate = self
            xmlParser?.parse()
            completion(self.instructionsURLs)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        valueWasSet = false
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "URL" && !valueWasSet {
            valueWasSet = true
            instructionsURLs.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
    
}
