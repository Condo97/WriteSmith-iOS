//
//  HTTPSHandler.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import Foundation

protocol HTTPSHelperDelegate: AnyObject {
    func didRegisterUser(json: [String: Any])
    func getRemaining(json: [String: Any])
    func getChat(json: [String: Any])
}

class HTTPSHelper {
    static func registerUser(delegate: HTTPSHelperDelegate) {
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.registerUesr)")!
        let postBody = "{}"
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = postBody.data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("ERRROR")
                print(error)
            } else if let data = data {
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any]
                        delegate.didRegisterUser(json: json!)
                    } catch {
                        
                    }
                }
            }
        })
        
        task.resume()
    }
    
    static func getRemaining(delegate: HTTPSHelperDelegate, authToken: String) {
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getRemaining)")!
        
        let postBody = """
        {
            "authToken": "\(authToken)"
        }
        """
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = postBody.data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error in getRemaining()")
                print(error)
            } else if let data = data {
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        delegate.getRemaining(json: json!)
                    } catch {
                        
                    }
                }
            }
        })
        
        task.resume()
    }
    
    static func getChat(delegate: HTTPSHelperDelegate, authToken: String, inputText: String) {
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getChat)")!
        
        let postBody = """
        {
            "authToken": "\(authToken)",
            "inputText": "\(inputText.replacingOccurrences(of: "\n", with: ""))"
        }
        """
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = postBody.data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("ERRROR")
                print(error)
            } else if let data = data {
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any]
                        delegate.getChat(json: json!)
                    } catch {
                        
                    }
                }
            }
        })
        
        task.resume()
    }
}
