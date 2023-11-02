//
//  HTTPSClient.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

class HTTPSClient {
    
    static func post(url: URL, body: Codable, headers: [String: String]?) async throws -> (Data, URLResponse) {
        // Try encoding body object to JSON
        let bodyData = try JSONEncoder().encode(body)
        
        // Create the request object
        var request = URLRequest(url: url)
        
        // Set request method and body
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        // Set headers if not nil
        if headers != nil {
            headers!.forEach({k, v in
                request.setValue(v, forHTTPHeaderField: k)
            })
        }
        
        // Get the shared URL Session
        let session = URLSession.shared
        let (data, response) = try await session.data(for: request)
        
        return (data, response)
    }
    
    
    // TODO: Remove because this is now legacy
    static func post(url: URL, body: Codable, headers: [String: String]?, completion: @escaping (Data?, Error?)->Void) throws {
        // Try encoding body object to JSON
        let bodyData = try JSONEncoder().encode(body)
        
        // Create the request object
        var request = URLRequest(url: url)
        
        // Set request method and body
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        // Set headers if not nil
        if headers != nil {
            headers!.forEach({k, v in
                request.setValue(v, forHTTPHeaderField: k)
            })
        }
        
        // Get the shared URL Session
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {data, response, error in
            // Print error message here first
            if let error = error {
                print("HTTPSClient Post - Error getting response")
                print(error)
            }
            
            // Completion block
            completion(data, error)
        })
        
        task.resume()
    }
    
}
