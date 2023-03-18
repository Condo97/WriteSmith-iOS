//
//  HTTPSHandler.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import Foundation

protocol HTTPSHelperDelegate: AnyObject {
    func didRegisterUser(json: [String: Any]?)
    func didGetAndSaveImportantConstants(json: [String: Any]?)
//    func didGetDisplayPrice(json: [String: Any])
    func getRemaining(json: [String: Any]?)
    func getChat(json: [String: Any]?)
    func getChatError()
//    func didGetShareURL(json: [String: Any])
}

class HTTPSHelper {
    static func registerUser(delegate: HTTPSHelperDelegate?) {
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
                        delegate?.didRegisterUser(json: json)
                    } catch {
                        print("Error serializing registerUesr() JSON from data")
                    }
                }
            }
        })
        
        task.resume()
    }
    
    static func getAndSaveImportantConstants(delegate: HTTPSHelperDelegate?) {
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getImportantConstants)")!
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
                        
                        // Let's just save all the stuff here, why not
                        if let body = json?["Body"] as? [String: Any] {
                            
                            // Save Share URL
                            if let shareURL = body[HTTPSResponseConstants.shareURL] as? String {
                                UserDefaults.standard.set(shareURL, forKey: Constants.userDefaultStoredShareURL)
                            }
                            
                            // Save Free Essay Cap
                            if let essayCap = body[HTTPSResponseConstants.freeEssayCap] as? Int {
                                UserDefaults.standard.set(essayCap, forKey: Constants.userDefaultStoredFreeEssayCap)
                            }
                            
                            // Save Weekly Display Price
                            if let weeklyDisplayPrice = body[HTTPSResponseConstants.weeklyDisplayPrice] as? String {
                                if let monthlyDisplayPrice = body[HTTPSResponseConstants.monthlyDisplayPrice] as? String {
                                    UserDefaults.standard.set(weeklyDisplayPrice, forKey: Constants.userDefaultStoredWeeklyDisplayPrice)
                                    UserDefaults.standard.set(monthlyDisplayPrice, forKey: Constants.userDefaultStoredMonthlyDisplayPrice)
                                } else {
                                    UserDefaults.standard.set(Constants.defaultWeeklyDisplayPrice, forKey: Constants.userDefaultStoredWeeklyDisplayPrice)
                                    UserDefaults.standard.set(Constants.defaultMonthlyDisplayPrice, forKey: Constants.userDefaultStoredMonthlyDisplayPrice)
                                }
                            } else {
                                UserDefaults.standard.set(Constants.defaultWeeklyDisplayPrice, forKey: Constants.userDefaultStoredWeeklyDisplayPrice)
                                UserDefaults.standard.set(Constants.defaultMonthlyDisplayPrice, forKey: Constants.userDefaultStoredMonthlyDisplayPrice)
                            }
                        } else {
                            UserDefaults.standard.set(Constants.defaultWeeklyDisplayPrice, forKey: Constants.userDefaultStoredWeeklyDisplayPrice)
                            UserDefaults.standard.set(Constants.defaultMonthlyDisplayPrice, forKey: Constants.userDefaultStoredMonthlyDisplayPrice)
                        }
                        
                        // Now once it's done call the delgate
                        delegate?.didGetAndSaveImportantConstants(json: json)
                    } catch {
                        print("Error serializing registerUesr() JSON from data")
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
                        delegate.getRemaining(json: json)
                    } catch {
                        print("Error serializing getRemaining() JSON from data")
                    }
                }
            }
        })
        
        task.resume()
    }
    
    static func getChat(delegate: HTTPSHelperDelegate, authToken: String, inputText: String) {
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getChat)")!
        
//        let authToken = "4U+VN3v/lu6ZB6C2d6OBdIC5q6sBIcAO/mLyNT4WQjoJNvJGHy7U1IPpO1RZ6VLfJ5HhK/uYlHz7POiXDP7Gz53ziP7Y8w095z/qoN9mmve/0e81d7B2Vgtrt1ilzwg8I80Dw7vxLwg9aCroueGTV5h9FuSLU894fwZ0S4ooVa0="
        
        let postBody = """
        {
            "authToken": "\(authToken)",
            "inputText": "\(inputText.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "”"))"
        }
        """ // Replace occurances of \", which are automatically made from standard quotations from user input
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = postBody.data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("ERRROR")
                print(error)
                
                delegate.getChatError()
            } else if let data = data {
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any]
                        delegate.getChat(json: json)
                    } catch {
                        print("Error serializing getChat() JSON from data")
                    }
                }
            }
        })
        
        task.resume()
    }
}
