//
//  LegoPartsController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 3/12/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class LegoPartsController {
    
    static let shared = LegoPartsController()
    
    let baseURL = "https://rebrickable.com/api/v3/lego/sets/"
    
    func fetchParts(bricksetLegoSet: LegoSet, completion: @escaping ([LegoPart]?) -> Void) {
        
        //attempts find the legoset's id on rebrickable.com in order to use their api methods
        findRebrickableID(bricksetLegoSet: bricksetLegoSet) { (rebrickableID) in
            
            let apiKey: String = "key=6a19ec0901e39bd6506c33786cdaad74"
            
            if let rebrickableID = rebrickableID, let startURL = URL(string: "\(self.baseURL)\(rebrickableID)/parts/?\(apiKey)") {
                
                var parts: [LegoPart] = []
                var group = DispatchGroup()
                
                func populateParts(with url: URL) {
                    group.enter()
                    
                    NetworkController.performNetworkRequest(url: url, completion: { (data, error) in
                        
                        if let error = error {
                            print(error.localizedDescription)
                            group.leave()
                            return
                        }

                        if let data = data {
                            do {
                                let jsonObjects = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                if let topDictionary = jsonObjects as? Dictionary<String, Any>,
                                    let partDicts = topDictionary["results"] as? [Dictionary<String, Any>] {
                                    
                                    parts.append(contentsOf: partDicts.compactMap { LegoPart(dict: $0) })
                                    
                                    if let additionalPage = topDictionary["next"] as? String, let nextURL = URL(string: "\(additionalPage)") {
                                        populateParts(with: nextURL)
                                    }
                                    
                                    group.leave()
                                    return
                                }
                                
                            } catch {
                                print("Could not decode json")
                            }
                        }
                    })
                }
                
                populateParts(with: startURL)
                
                group.notify(queue: .main, execute: {
                    completion(parts)
                })
                
            } else {
                completion(nil)
            }
        }
        
    }
    
    fileprivate func findRebrickableID(bricksetLegoSet: LegoSet, completion: @escaping (String?) -> Void) {
        
        let queries: [String : String] = [
            "key" : "6a19ec0901e39bd6506c33786cdaad74",
            "search" : bricksetLegoSet.name,
            "min_parts" : String(bricksetLegoSet.pieces - 10),
            "max_parts" : String(bricksetLegoSet.pieces + 10),
            "min_year" : String(bricksetLegoSet.year),
            "max_year" : String(bricksetLegoSet.year)
        ]
        
        if let url = URL(string: baseURL)!.withQueries(queries) {
            NetworkController.performNetworkRequest(url: url) { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil)
                    return
                }
                
                if let data = data {
                    do {
                        let jsonObjects = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        if let topDictionary = jsonObjects as? Dictionary<String, Any>,
                            let results = topDictionary["results"] as? [Dictionary<String, Any>] {
                            
                            var legoSets: [LegoSet] = []
                            for result in results {
                                if let set = LegoSet(rebrickableDictionary: result) {
                                    legoSets.append(set)
                                }
                            }
                            
                            if legoSets.count != 0 {
                                var rebrickableLegoSet = legoSets[0]
                                
                                if legoSets.count > 1 {
                                    //finds the set with closest amount of pieces to the original brickset legoset
                                    let closestSet = legoSets.reduce(rebrickableLegoSet) { abs($1.pieces - bricksetLegoSet.pieces) < abs($0.pieces - bricksetLegoSet.pieces) ? $1 : $0 }
                                    rebrickableLegoSet = closestSet
                                }
                                
                                completion(rebrickableLegoSet.id)
                                return
                            }
                            
                        }
                        
                    } catch {
                        print("Could not decode json")
                    }
                }
                
                print("Data returned was not valid")
                completion(nil)
                return
                
            }
        } else {
            print("A url could not be created")
            completion(nil)
            return
        }
        
    }
    
}
