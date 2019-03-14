//
//  PDFController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/11/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class PDFController: NSObject, XMLParserDelegate {
    
    static let shared = PDFController()
    let baseURL = "https://brickset.com/api/v2.asmx/getInstructions?apiKey=B5sG-5uAN-22mW&setID="
    
    var legoSet: LegoSet?
    var allURLs: [String] = []
    var pdfURLs: [String] = []
    
    //xml parser variables
    fileprivate var urlDescriptions: [String] = []
    fileprivate var currentElement: String = ""
    fileprivate var valueWasSet: Bool = false
    
    func fetchInstructionURLs(for legoSet: LegoSet, completion: @escaping ([String]) -> Void) {
        self.legoSet = legoSet
        allURLs.removeAll()
        pdfURLs.removeAll()
        urlDescriptions.removeAll()
        
        DispatchQueue.global(qos: .utility).async {
            let xmlParser = XMLParser(contentsOf: URL(string: self.baseURL + legoSet.id)!)
            xmlParser?.delegate = self
            xmlParser?.parse()
            
            //example urlDescription: "BI 3005/60 , 60031 V29 1/2"
            //do tests with "bank" #8461
            
            //pdfURLs will have duplicates removed but keeps a copy of the original
            self.allURLs.append(contentsOf: self.pdfURLs)
            
            //if all urls had the description "{No longer listed at LEGO.com}" they won't be listed in pdfURLs
            if self.pdfURLs.count == 0 && self.allURLs.count > 0 {
                completion(self.allURLs)
                return
            }
            
            if self.pdfURLs.count > 1 {
                
                var instructionsFound: Int?
                var breakLoop: Bool = false
                
                for descriptionIndex in 0...self.urlDescriptions.count - 1 {
                    var description = self.urlDescriptions[descriptionIndex]
                    description.removeFirst(description.count / 2)
                    
                    for index in 1...self.urlDescriptions.count {
                        if description.contains("1/\(index)") {
                            instructionsFound = index
                            breakLoop = true
                            break
                        }
                    }
                    
                    if breakLoop {
                        break
                    }
                }
                
                guard let instructionsAmount = instructionsFound else {
                    // if it could not determine how many instructions there's supposed to be,
                    // return the first if there's two because the seconds a duplicate, otherwise
                    // a parsing error probably occured so return all
                    if self.pdfURLs.count == 2 {
                        completion([self.pdfURLs.first!])
                        return
                    } else {
                        completion(self.pdfURLs)
                        return
                    }
                }
                
                //if the amount of urls found is the same as the instructions amount found then no duplicates exist
                if self.pdfURLs.count == instructionsAmount {
                    completion(self.pdfURLs)
                    return
                }
                
                var shouldDeleteDuplicates = false
                var pdfIndexesToDelete: [Int] = []
                
                for instructionsIndex in 0...instructionsAmount - 1 {
                    shouldDeleteDuplicates = false
                    
                    for descriptionIndex in 0...self.urlDescriptions.count - 1 {
                        var description = self.urlDescriptions[descriptionIndex]
                        description.removeFirst(description.count / 2)
                        
                        if description.contains("\(instructionsIndex + 1)/\(instructionsAmount)") || description.contains("\(instructionsIndex + 1) / \(instructionsAmount)") {
                            if shouldDeleteDuplicates {
                                pdfIndexesToDelete.append(descriptionIndex)
                            } else {
                                shouldDeleteDuplicates = true
                            }
                        }
                        
                    }
                }
                
                self.pdfURLs.remove(at: pdfIndexesToDelete)

            }
            
            completion(self.pdfURLs)
        }
    }
    
    //========================================
    // MARK: - XML Parser Delegate
    //========================================
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        valueWasSet = false
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "URL" && !valueWasSet {
            valueWasSet = true
            pdfURLs.append(string)
        } else if currentElement == "description" && !valueWasSet {
            valueWasSet = true
            
            //this description is always associated with duplicate pdfs
            if string == "{No longer listed at LEGO.com}" {
                allURLs.append(pdfURLs.removeLast())
                if let legoSet = legoSet, let instructionsCount = Int(legoSet.instructionsCount) {
                    legoSet.instructionsCount = String(instructionsCount - 1)
                }
            } else {
                urlDescriptions.append(string)
            }
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
    
}

//========================================
// MARK: - Extensions
//========================================

extension Array {
    mutating func remove(at indexes: [Int]) {
        var mutableIndexes = indexes
        
        for _ in 0...indexes.count - 1 {
            let value = mutableIndexes.removeFirst()
            if mutableIndexes.contains(value) {
                print("\n\nWARNING: duplicate indexes were detected in Array extension remove(at indexes: [Int])\n\n")
                return
            }
        }
        
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
}
