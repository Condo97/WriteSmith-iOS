//
//  ConversationChatGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/24/23.
//

import CoreData
import Foundation
import SwiftUI
import UIKit

class ConversationChatGenerator: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var isGenerating: Bool = false
    
    @Published var alertShowingUserChatNotSaved = false
    
    
    private let imageURLChatIndex: Int = 0
    private let imageChatIndex: Int = 0
    private let textChatIndex: Int = 0
    
//    func addChat(message: String, sender: Sender, to conversationObjectID: NSManagedObjectID) async throws {
//        // TODO: Do I have to get the permanent object ID for conversationObjectID
//        try await ChatCDHelper.appendChat(
//            sender: sender,
//            text: message,
//            to: conversationObjectID)
//    }
    
    /***
     Generate Chat
     
     Takes multiple inputs and splits them into new Chats with one input per chat, then gets a Chat with the current Conversation with all the new Chats
     Okay, but instead, should I just do it all in one chat and parse it out to make it look like multiple chats in ChatView's list? I think they should be multiple chats because then the user would be able to delete an image or image url but maintain the other parts they specified in the input
     */
    func generateChat(input: String?, image: UIImage?, imageURL: String?, conversation: Conversation, authToken: String, isPremium: Bool, remainingUpdater: RemainingUpdater, in managedContext: NSManagedObjectContext) async throws {
        // Ensure can generate, which is a variable
        guard canGenerateChat(isPremium: isPremium) else {
            return
        }
        
        // Create User Image URL Chat if imageURL is not nil and User Image Chat if image is not null and User Text Chat if input is not nil and save on main queue
        let userImageURLChat: Chat? = {
            // Unwrap imageURL, otherwise return nil
            guard let imageURL = imageURL else {
                return nil
            }
            
            let userImageURLChat = Chat(context: managedContext)
            
            // Set and save User Image URL Chat
            userImageURLChat.imageURL = imageURL
            userImageURLChat.sender = Sender.user.rawValue
            userImageURLChat.date = Date()
            userImageURLChat.conversation = conversation
            
            return userImageURLChat
        }()
        
        let userImageChat: Chat? = {
            // Unwrap image, otherwise return nil
            guard let image = image else {
                return nil
            }
            
            let userImageChat = Chat(context: managedContext)
            
            // Set and save User Image Chat
            userImageChat.imageData = image.pngData()
            userImageChat.sender = Sender.user.rawValue
            userImageChat.date = Date().advanced(by: 0.1)
            userImageChat.conversation = conversation
            
            return userImageChat
        }()
        
        let userTextChat: Chat? = {
            // Unwrap input and ensure it's not empty, otherwise return nil
            guard let input = input, !input.isEmpty else {
                return nil
            }
            
            let userTextChat = Chat(context: managedContext)
            
            // Set and save User Text Chat
            userTextChat.text = input
            userTextChat.sender = Sender.user.rawValue
            userTextChat.date = Date().advanced(by: 0.2)
            userTextChat.conversation = conversation
            
            return userTextChat
        }()
        
        DispatchQueue.main.async {
            do {
                try managedContext.save()
            } catch {
                // TODO: Handle errors
                print("Error saving userChat to CoreData in ConversationChatGenerator... \(error)")
//                throw ChatGeneratorError.addUserChat
                self.alertShowingUserChatNotSaved = true
            }
        }
        
        // Defer setting canGenerate to true and isLoading and isGenerating to false to ensure they are set to false when this method completes
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isGenerating = false
            }
        }
        
        DispatchQueue.main.async {
            // Set isLoading to true
            self.isLoading = true
        }
        
        // Create AI chat in CoreData
        let aiChat = Chat(context: managedContext)
        
        aiChat.sender = Sender.ai.rawValue
        aiChat.conversation = conversation
        aiChat.date = Date().advanced(by: 0.3)
        
        // Get selected model
        let selectedModel = GPTModelHelper.currentChatModel
        
        // Create GetChatRequest Body Chats from the userImageURLChat, userImageChat, and userTextChat that can be unwrapped with indices in that order
        let requestBuilder = GetChatRequest.Builder(
            authToken: authToken,
            behavior: nil, // TODO: Implement behavior functionality with topics
            conversationID: conversation.conversationID,
            usePaidModel: GPTModelTierSpecification.paidModels.contains(where: {$0 == selectedModel}))
        
        if let userImageURLChat = userImageURLChat {
            requestBuilder.addChat(
                index: imageURLChatIndex,
                input: userImageURLChat.text,
                imageData: userImageURLChat.imageData,
                imageURL: userImageURLChat.imageURL,
                sender: Sender(rawValue: userImageURLChat.sender ?? "") ?? .user) // TODO: Is the user being the default sender here good? Should I even send to the server as Sender instead of the string?
        }
        
        if let userImageChat = userImageChat {
            requestBuilder.addChat(
                index: imageChatIndex,
                input: userImageChat.text,
                imageData: userImageChat.imageData,
                imageURL: userImageChat.imageURL,
                sender: Sender(rawValue: userImageChat.sender ?? "") ?? .user) // TODO: Is the user being the default sender here good? Should I even send to the server as Sender instead of the string?
        }
        
        if let userTextChat = userTextChat {
            requestBuilder.addChat(
                index: textChatIndex,
                input: userTextChat.text,
                imageData: userTextChat.imageData,
                imageURL: userTextChat.imageURL,
                sender: Sender(rawValue: userTextChat.sender ?? "") ?? .user) // TODO: Is the user being the default sender here good? Should I even send to the server as Sender instead of the string?
        }
        
        let request = requestBuilder.build()
        
        // Get stream
        let stream = ChatWebSocketConnector.getChatStream()
        
        // Send request TODO: Handle errors here if necessary
        try await stream.send(.string(String(data: JSONEncoder().encode(request), encoding: .utf8)!))
        PasteboardHelper.copy(String(data: try JSONEncoder().encode(request), encoding: .utf8)!)
        // Create firstMessage to get when the first message is processed
        var firstMessage = true
        
        // Define nullEquivalentString
        let nullEquivalentString = "null"
        
        // Define important variables to get during stream
        var fullOutput: String = ""
        var finishReason: ChatFinishReasons?
        
        // Stream generation, updating AI chat in managed context
        do {
            for try await message in stream {
                if firstMessage {
                    // Do light haptic
                    HapticHelper.doSuccessHaptic()
                    
                    // Set isLoading to false and isGenerating to true
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isGenerating = true
                    }
                    
                    firstMessage = false
                }
                
                // Parse message, and if it cannot be unwrapped continue
                guard let messageData = {
                    switch message {
                    case .data(let data):
                        return data
                    case .string(let string):
                        return string.data(using: .utf8)
                    @unknown default:
                        print("Message wasn't stirng or data when parsing message stream! :O")
                        return nil
                    }
                }() else {
                    print("Could not unwrap messageData in message stream! Skipping...")
                    continue
                }
                
                // Parse message to GetChatResponse
                let getChatResponse: GetChatResponse
                do {
                    getChatResponse = try JSONDecoder().decode(GetChatResponse.self, from: messageData)
                } catch {
                    print("Error decoding messageData to GetChatResponse so skipping... \(error)")
                    continue
                }
                
                // Unwrap and add outputText to fullOutput
                if let outputText = getChatResponse.body.outputText {
                    fullOutput += outputText
                }
                
                // Set finishReason
                if let responseFinishReasonString = getChatResponse.body.finishReason {
                    if let responseFinishReason = ChatFinishReasons(rawValue: responseFinishReasonString) {
                        finishReason = responseFinishReason
                    }
                }
                
                // Set remaining
                if let responseRemaining = getChatResponse.body.remaining {
                    remainingUpdater.set(drinksRemaining: responseRemaining)
                }
                
                await MainActor.run { [fullOutput] in
                    // Set aiChat text to fullOutput
                    aiChat.text = fullOutput
                    
                    // Set userImageURLChat chatID to inputChat with index imageURLChatIndex
                    if let responseInputImageURLChat = getChatResponse.body.inputChats.first(where: {$0.index == imageURLChatIndex}) {
                        if let responseInputChatIDCastInt64 = Int64(exactly: responseInputImageURLChat.chatID) {
                            userImageURLChat?.chatID = responseInputChatIDCastInt64
                        }
                    }
                    
                    // Set userImageChat chatID to inputChat with index imageChatIndex
                    if let responseInputImageChat = getChatResponse.body.inputChats.first(where: {$0.index == imageChatIndex}) {
                        if let responseInputChatIDCastInt64 = Int64(exactly: responseInputImageChat.chatID) {
                            userImageChat?.chatID = responseInputChatIDCastInt64
                        }
                    }
                    
                    // Set userTextChat chatID to inputChat with index textChatIndex
                    if let responseInputTextChat = getChatResponse.body.inputChats.first(where: {$0.index == textChatIndex}) {
                        if let responseInputChatIDCastInt64 = Int64(exactly: responseInputTextChat.chatID) {
                            userTextChat?.chatID = responseInputChatIDCastInt64
                        }
                    }
                    
//                    // Set userChat chatID to inputChatID
//                    if let inputChatID = getChatResponse.body.inputChatID, inputChatID > 0 {
//                        if let inputChatIDCastInt64 = Int64(exactly: inputChatID) {
//                            userChat.chatID = inputChatIDCastInt64
//                        }
//                    }
                    
                    // Set aiChat chatID to outputChatID
                    if let outputChatID = getChatResponse.body.outputChatID, outputChatID > 0 {
                        if let outputChatIDCastInt64 = Int64(exactly: outputChatID) {
                            aiChat.chatID = outputChatIDCastInt64
                        }
                    }
                    
                    // Set conversation conversationID to conversationID
                    if let conversationID = getChatResponse.body.conversationID, conversationID > 0 {
                        if let conversationIDCastInt64 = Int64(exactly: conversationID) {
                            conversation.conversationID = conversationIDCastInt64
                        }
                    }
                    
                    // Save to CoreData
                    do {
                        try managedContext.save()
                    } catch {
                        // TODO: Handle errors
                        print("Error saving to CoreData in ConversationChatGenerator... \(error)")
                    }
                }
                
            }
        } catch {
            // TODO: Handle errors
//            print("Error getting the next message in stream in ConversationChatGenerator... \(error)")
        }
        
        // Ensure first message has been generated, otherwise return before saving context
        guard !firstMessage else {
            // TODO: Handle errors
            throw ChatGeneratorError.nothingFromServer
        }
        
        DispatchQueue.main.async { [finishReason] in
            // Add additional text if finishReason is length and isPremium is false
            if finishReason == .length && !isPremium {
                aiChat.text? += Constants.lengthFinishReasonAdditionalText
            }
            
            // Update conversation latestChatText to aiChat text if it can be unwrapped and latestChatDate to Date
            if let aiChatText = aiChat.text {
                conversation.latestChatText = aiChatText
                conversation.latestChatDate = Date()
            }
        
            // Save to CoreData
            do {
                try managedContext.save()
            } catch {
                // TODO: Handle errors
                print("Error saving to CoreData in ConversationChatGenerator... \(error)")
            }
        }
    }
    
    func canGenerateChat(isPremium: Bool) -> Bool {
        return true
        
        // Can never generate if isLoading
        if isLoading {
            return false
        }
        
        // Can not generate if isGenerating and is not isPremium
        if isGenerating && !isPremium {
            return false
        }
        
        // All other cases can generate
        return true
    }
    
}
