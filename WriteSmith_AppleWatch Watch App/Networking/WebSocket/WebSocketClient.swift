//
//  WebSocketClient.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/17/23.
//

import Foundation

class WebSocketClient {
    
    static func connect(url: URL, headers: [String: String]?) -> SocketStream {
        var urlRequest = URLRequest(url: url)
        
        headers?.forEach({k, v in
            urlRequest.addValue(v, forHTTPHeaderField: k)
        })
        
        let socketConnection = URLSession.shared.webSocketTask(with: urlRequest)
        
        return SocketStream(task: socketConnection)
    }
    
//    static func testWebSocketConnection() {
//        var urlRequest = URLRequest(url: URL(string: "\(WebSocketConstants.chitChatWebSocketServer)\(WebSocketConstants.getChatStream)")!)
//        urlRequest.addValue(AuthHelper.get()!, forHTTPHeaderField: "authToken")
//        urlRequest.addValue("Say hi", forHTTPHeaderField: "inputText")
//        
//        let socketConnection = URLSession.shared.webSocketTask(with: urlRequest)
//        
//        let stream = SocketStream(task: socketConnection)
//        
//        Task {
//            do {
//                for try await message in stream {
//                    print(message)
//                }
//            } catch {
//                
//            }
//        }
//    }
    
}
