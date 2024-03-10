//
//  ExploreChatGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/24/23.
//

import CoreData
import Foundation
import UIKit

class ExploreChatGenerator: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var isGenerating: Bool = false
    
    @Published var generatedChats: [ExploreChat] = []
    
    private var canGenerate = true
    
    
//    func addChat(message: String, sender: Sender, to conversationObjectID: NSManagedObjectID) async throws {
//        // TODO: Do I have to get the permanent object ID for conversationObjectID
//        try await ChatCDHelper.appendChat(
//            sender: sender,
//            text: message,
//            to: conversationObjectID)
//    }
    
    func generateExplore(input: String, image: UIImage?, imageURL: String?, isPremium: Bool, remainingUpdater: RemainingUpdater) async throws {
        // Ensure can generate, which is a variable
        guard canGenerate else {
            return
        }
        
        // Defer setting canGenerate to true and isLoading and isGenerating to false to ensure they are set to false when this method completes
        defer {
            canGenerate = true
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.isGenerating = false
            }
        }
        
        // Set canGenerate to false since it will be generating a chat
        canGenerate = false
        
        // Append exploreChat and get ID
        var exploreChat = ExploreChat()
        generatedChats.append(exploreChat)
        let generatedChatID = exploreChat.id
//        generatedText = ""
        
        DispatchQueue.main.async {
            // Set isLoading to true
            self.isLoading = true
        }
        
        // Get selected model
        let selectedModel = GPTModelHelper.currentChatModel
        
        // Build GetChatRequest
        let request: GetChatRequest
        do {
            request = GetChatRequest.Builder(
                authToken: try await AuthHelper.ensure(),
                behavior: nil, // TODO: Implement behavior
                conversationID: Constants.defaultConversationID,
                usePaidModel: GPTModelTierSpecification.paidModels.contains(where: {$0 == selectedModel}))
            .addChat(
                index: 0,
                input: input,
                imageData: image?.pngData(),
                imageURL: imageURL,
                sender: .user)
            .build()
        } catch {
            throw ChatGeneratorError.invalidAuthToken
        }
        
        // Create and unwrap requestString from JSONEncoded request, otherwise return
        guard let requestString = String(data: try JSONEncoder().encode(request), encoding: .utf8) else {
            // TODO: Handle errors
            print("Could not unwrap requestString in EssayChatGenerator!")
            return
        }
        
        // Get stream
        let stream = ChatWebSocketConnector.getChatStream()
        
        // Send request TODO: Handle errors here if necessary
        try await stream.send(.string(requestString))
        
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
                    // Do success haptic
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
                        print("Message wasn't string or data when parsing message stream! :O")
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
                    
                    // Catch as StatusResponse
                    let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: messageData)
                    
                    if statusResponse.success == 5 {
                        Task {
                            do {
                                try await AuthHelper.regenerate()
                            } catch {
                                print("Error regenerating authToken in HTTPSConnector... \(error)")
                            }
                        }
                    }
                    
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
                    // Get generatedChatIndex and if it can be unwrapped set the generatedChat at the index to fullOutput
                    if let generatedChatIndex = generatedChats.firstIndex(where: {$0.id == generatedChatID}) {
                        generatedChats[generatedChatIndex].chat = fullOutput
                    }
//                    generatedText = fullOutput
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
                if let generatedChatIndex = self.generatedChats.firstIndex(where: {$0.id == generatedChatID}) {
                    self.generatedChats[generatedChatIndex].chat += Constants.lengthFinishReasonAdditionalText
                }
            }
        }
    }
    
}
