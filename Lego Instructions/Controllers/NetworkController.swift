//
//  NetworkController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/5/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class NetworkController {
    static func performNetworkRequest(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                print("There was a problem fetching data")
                print(error as Any)
            }
            
            completion(data, error)
            
            }.resume()
    }
}


extension URL {
    
    func withQueries(_ queries: [String: String]) -> URL? {
        
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.compactMap { URLQueryItem(name: $0, value: $1) }
        return components?.url
    }
}
