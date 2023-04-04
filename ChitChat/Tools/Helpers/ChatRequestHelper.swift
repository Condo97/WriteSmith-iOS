//
//  ChatRequestHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/2/23.
//

import Foundation

class ChatRequestHelper: Any {
    
    /***
     Gets the chat response from the server in the completion block along with a boolean denoting if the finishReason was token length or not and the amount remaining for the user
     */
    static func get(inputText: String, completion: @escaping (String, String, Int)->Void) {
        AuthHelper.ensure(completion: {authToken in
            let getChatRequest = GetChatRequest(authToken: authToken, inputText: inputText)
            HTTPSConnector.getChat(request: getChatRequest, completion: {getChatResponse in
                // Set finish reason to limit if Success was 51, showing that the limit was reached TODO: Maybe change this in the server from an error? Or is this just not a great way to do this?
                var finishReason = getChatResponse.body.finishReason
                if getChatResponse.success == 51 {
                    finishReason = FinishReasons.limit
                }
                
                // Call completion block
                completion(getChatResponse.body.outputText, finishReason, getChatResponse.body.remaining)
            })
        })
    }
    
}
