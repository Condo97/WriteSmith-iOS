//
//  IAPHTTPSClient.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 6/30/23.
//

import Foundation

//protocol IAPHTTPSClientDelegate {
//    func didGetIAPStuffFromServer(json: [String: Any])
//}

class IAPHTTPSClient {
    
    static func getIAPStuffFromServer(authToken: String) async throws -> [String: Any]? {
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
        let (data, response) = try await session.data(for: request)
        
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
//        , completionHandler: { (data, response) in
//            if let error = error {
//                print("Error in GetIAPStuffFromServer")
//                print(error)
//            } else if let data = data {
//                DispatchQueue.main.async {
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any]
//                        
//                        delegate.didGetIAPStuffFromServer(json: json!)
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//        })
//        
//        task.resume()
    }
    
}
