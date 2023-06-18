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
    static func get(inputText: String, conversationID: Int?, model: GPTModels, completion: @escaping (_ outputText: String, _ finishReason: String, _ conversationID: Int?, _ remaining: Int)->Void) {
        AuthHelper.ensure(completion: {authToken in
            // TODO: Once the server has a better way to do calls than "free" and "paid" model, this will be simplified
            let usePaidModel = GPTModelTierSpecification.paidModels.contains(where: {$0 == model})
            
            let getChatRequest = GetChatRequest(authToken: authToken, inputText: inputText, conversationID: conversationID, usePaidModel: usePaidModel)
            HTTPSConnector.getChat(request: getChatRequest, completion: {getChatResponse in
                // Set finish reason to limit if Success was 51, showing that the limit was reached TODO: Maybe change this in the server from an error? Or is this just not a great way to do this?
                var finishReason = getChatResponse.body.finishReason
                if getChatResponse.success == 51 {
                    finishReason = FinishReasons.limit
                }
                
                // Call completion block TODO: I filled in the optional values for outputText, finishReason, and remaining, maybe need to fix this and do an analysis on the best way to handle these issues
                completion(getChatResponse.body.outputText ?? "", finishReason ?? "", getChatResponse.body.conversationID, getChatResponse.body.remaining ?? -1)
            })
        })
    }
    
}
