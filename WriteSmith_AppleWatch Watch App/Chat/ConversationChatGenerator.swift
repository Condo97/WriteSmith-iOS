//
//  ConversationChatGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/24/23.
//

import CoreData
import Foundation

class ConversationChatGenerator: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var isGenerating: Bool = false
    
    @Published var alertShowingUserChatNotSaved = false
    
    
//    func addChat(message: String, sender: Sender, to conversationObjectID: NSManagedObjectID) async throws {
//        // TODO: Do I have to get the permanent object ID for conversationObjectID
//        try await ChatCDHelper.appendChat(
//            sender: sender,
//            text: message,
//            to: conversationObjectID)
//    }
    
    func generateChat(input: String, conversation: Conversation, authToken: String, isPremium: Bool, remainingUpdater: RemainingUpdater, in managedContext: NSManagedObjectContext) async throws {
        // Ensure can generate, which is a variable
        guard canGenerateChat(isPremium: isPremium) else {
            return
        }
        
        // Create User Chat and save on main queue
        let userChat = Chat(context: managedContext)
        
        // Set and save User Chat
        userChat.text = input
        userChat.sender = Sender.user.rawValue
        userChat.date = Date()
        userChat.conversation = conversation
        
        do {
            try await managedContext.perform {
                try managedContext.save()
            }
        } catch {
            // TODO: Handle errors
            print("Error saving userChat to CoreData in ConversationChatGenerator... \(error)")
//                throw ChatGeneratorError.addUserChat
            self.alertShowingUserChatNotSaved = true
        }
        
        // Defer setting canGenerate to true and isLoading and isGenerating to false to ensure they are set to false when this method completes
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isGenerating = false
            }
        }
        
        await MainActor.run {
            // Set isLoading to true
            self.isLoading = true
        }
        
        // Create AI chat in CoreData
        let aiChat = Chat(context: managedContext)
        
        aiChat.sender = Sender.ai.rawValue
        aiChat.conversation = conversation
        aiChat.date = Date()
        
        // Get selected model
        let selectedModel = GPTModelHelper.currentChatModel
        
        // Build GetChatRequest
        let request: GetChatRequest
        do {
            request = GetChatRequest(
                authToken: authToken,
                inputText: input,
                conversationID: conversation.conversationID,
                usePaidModel: GPTModelTierSpecification.paidModels.contains(where: {$0 == selectedModel}))
        } catch {
            throw ChatGeneratorError.invalidAuthToken
        }
        
        // Get stream
        let stream = ChatWebSocketConnector.getChatStream(request: request)
        
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
                    HapticHelper.doLightHaptic()
                    
                    // Set isLoading to false and isGenerating to true
                    await MainActor.run {
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
                    
                    // Set userChat chatID to inputChatID
                    if let inputChatID = getChatResponse.body.inputChatID, inputChatID > 0 {
                        if let inputChatIDCastInt64 = Int64(exactly: inputChatID) {
                            userChat.chatID = inputChatIDCastInt64
                        }
                    }
                    
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
        
        await MainActor.run { [finishReason] in
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
