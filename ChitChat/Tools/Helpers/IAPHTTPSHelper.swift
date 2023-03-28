//
//  IAPHTTPSHelper.swift
//  ChitChat
//
//  Created by Alex C on 9/26/22.
//

import Foundation

protocol IAPHTTPSHelperDelegate: AnyObject {
    func didValidateSaveUpdateReceipt(json: [String: Any])
    func didGetIAPStuffFromServer(json: [String: Any])
}

struct IAPHTTPSHelper {
    static func validateAndSaveReceipt(authToken: String, receiptData: Data, delegate: IAPHTTPSHelperDelegate) {
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.validateSaveUpdateReceipt)")!
        let postBody = """
        {
            "authToken": "\(authToken)",
            "receiptString": "\(receiptData.base64EncodedString(options: []))"
        }
    """
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = postBody.data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error in VaidateAndSaveReceipt")
                print(error)
            } else if let data = data {
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any]
                        delegate.didValidateSaveUpdateReceipt(json: json!)
                    } catch {
                        
                    }
                }
            }
        })
        
        task.resume()
    }
    
    static func getIAPStuffFromServer(authToken: String, delegate: IAPHTTPSHelperDelegate) {
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.getIAPStuff)")!
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
                print("Error in GetIAPStuffFromServer")
                print(error)
            } else if let data = data {
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any]
                        delegate.didGetIAPStuffFromServer(json: json!)
                    } catch {
                        
                    }
                }
            }
        })
        
        task.resume()
    }
}
