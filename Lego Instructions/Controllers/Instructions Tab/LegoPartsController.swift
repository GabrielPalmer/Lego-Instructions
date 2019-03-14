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
        
        convertToRebrickableSet(bricksetLegoSet: bricksetLegoSet) { (rebrickableSet) in
            
            let queries: Dictionary<String, String> = ["key" : "6a19ec0901e39bd6506c33786cdaad74"]
            
            if let rebrickableSet = rebrickableSet, let url = URL(string: "\(self.baseURL)\(rebrickableSet.id)/parts/")?.withQueries(queries) {
                NetworkController.performNetworkRequest(url: url, completion: { (data, error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        completion(nil)
                        return
                    }
                    
                    if let data = data {
                        do {
                            let jsonObjects = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let topDictionary = jsonObjects as? Dictionary<String, Any>,
                                let partDicts = topDictionary["results"] as? [Dictionary<String, Any>] {
                                
                                var parts: [LegoPart] = []
                                
                                for dict in partDicts {
                                    if let part = LegoPart(dict: dict) {
                                        parts.append(part)
                                    }
                                }
                                
                                completion(parts)
                                return
                            }
                            
                        } catch {
                            print("Could not decode json")
                        }
                    }
                })
                
            } else {
                completion(nil)
            }
        }
        
    }
    
    fileprivate func convertToRebrickableSet(bricksetLegoSet: LegoSet, completion: @escaping (LegoSet?) -> Void) {
        
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
                                
                                completion(rebrickableLegoSet)
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
