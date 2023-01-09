//
//  HTTPSHandler.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import Foundation

protocol HTTPSHelperDelegate: AnyObject {
    func didGetChatSonicTest(json: [String: Any])
}

class HTTPSHelper {
    static func getChatSonicTest(delegate: HTTPSHelperDelegate, inputText: String) {
        let url = HTTPSConstants.chatSonicURL!
        let postBody = """
        {
            "enable_google_results": "true",
            "enable_memory": "false",
            "input_text": "\(inputText)"
        }
        """
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("9fe1ae72-4d9d-498f-bc63-a43ff59f574e", forHTTPHeaderField: "X-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
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
                        delegate.didGetChatSonicTest(json: json!)
                    } catch {
                        
                    }
                }
            }
        })
        
        task.resume()
    }
}
