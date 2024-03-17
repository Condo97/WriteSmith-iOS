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
    
    @Published var isShowingPromoImageGenerationView = false
    
    var generatingChats: [Int64: String] = [:]
    
    private let imageGenerationConfirmationAIMessages: [String] = [
        "I'll try to create that for you...",
        "I'll make that image for you..."
    ]
    private let defaultImageGenerationConfirmationAIMessage: String = "I'll try to create that for you..."
    
    private let imageGenerationErrorAIMessages: [String] = [
        "Please try generating that again.",
        "Hmm, I had an issue generating your image. Please try again and double check your propmt to make sure it's appropriate.",
        "There was an issue generating your image. Please try rephrasing the prmopt, and make sure it's appropriate.",
        "There was an issue generating your image. Please try again.",
        "Hm, I couldn't generate that. Can you try something else?"
    ]
    private let defaultImageGenerationErrorAIMessage: String = "Please try generating that again."
    
    private let imageURLChatIndex: Int = 0
    private let imageChatIndex: Int = 0
    private let textChatIndex: Int = 0
    
    private let DEFAULT_CORE_DATA_NEW_CHAT_ID = 0 // Another approach would be setting the chatID.. but it seems to be pretty consistenlty 0 and though that's up to Apple to keep like that I feel like if it's not gonna be optional a new one will be zero ya know.. TODO: Reapproach this and maybe set initial chatIDs to a number manually, just that that adds a tiny bit of complexity so idk if I may just keep it like this
    
//    private let ITERATIONS_PER_UPDATE = 5
    private let UPDATES_PER_SECOND = 2
    
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
        /* Save User Chats */
        
        // Ensure can generate, which is a variable
        guard canGenerateChat(isPremium: isPremium) else {
            return
        }
        
        // Defer isLoading to set to false when function finishes
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            self.isLoading = true
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
        
        /* Check For and Do Image Generation */
        
        // First, userTextChat's text has to be unwrapped and not empty and userImageChat and userImageURLChat have to be nil or empty or whatever they can't exist for a prompt to be sent, it has to be only a text chat that the user sent
        var shouldGenerateImage: Bool = false
        var imageGenerationPrompt: String?
        if let userInput = userTextChat?.text, !userInput.isEmpty && userImageChat == nil && userImageURLChat == nil {
            // TODO: Maybe notify user if they attach an image they won't be generating a chat if they are trying to!
            
            // Second, check if the chat is or can be an image revision
            
            // Check if the previous AI chat contained an image.. that's reliable right?
            if try await previousAIChatContainsImage(conversation: conversation, in: managedContext) {
                // If so, ask the server if this is a request for revision
                let cicrirRequest = CheckIfChatRequestsImageRevisionRequest(
                    authToken: authToken,
                    chat: userInput)
                
                let cicrirResponse = try await HTTPSConnector.checkIfChatRequestsImageRevision(request: cicrirRequest)
                
                // If cicrirResponse requestedRevision is true, we are definitely generating an image so set generateImage to true and imageGenerationPrompt to userTextChatText
                if cicrirResponse.body.requestsImageRevision {
                    // Now to check for revisionss.. append all chats that are preceeded by an image in a chain until one is found that is not preceeded by an image into an input string and do image generation TODO: Is this a good idea?
                    let userChatImagePromptAndRevisionChain = try await getPreviousUserChatsTillPreceedingAIChatDoesNotContainImage(conversation: conversation, in: managedContext)
                    
                    // Create tempImageGenerationPrompt as an empty string and set to imageGenerationPrompt later to avoid setting to a force unwarpped variable
                    var tempImageGenerationPrompt = ""
                    
                    // Add each chatString in reversed userChatImagePromptAndRevisionChain to imageGenreationPrompt separate by a comma
                    for chatString in userChatImagePromptAndRevisionChain.reversed() {
                        // Append chatString to imageGenerationPrompt
                        tempImageGenerationPrompt.append(chatString)
                        
                        // Append ", " separator after appending chatString
                        tempImageGenerationPrompt.append(", ")
                    }
                    
                    // Append userTextChatText to imageGenerationPrompt
                    tempImageGenerationPrompt.append(userInput)
                    
                    // Set generateImage to true and set imageGenerationPrompt to tempImageGenerationPrompt
                    shouldGenerateImage = true
                    imageGenerationPrompt = tempImageGenerationPrompt
                }
            }
            
            // Check if imageGenerationPrompt is nil or empty--meaning there was no previous image, therefore no chain, and therefore this chat could still want image generation so check with server and set shouldGenerateImgae and imageGenerationPrompt accordingly
            if imageGenerationPrompt == nil {
                // Check if chat wants image generation
                if try await promptWantsImageGeneration(
                    authToken: authToken,
                    prompt: userInput) {
                    // Set shouldGenerateImage to true and imageGenerationPrompt to userTextChatText
                    shouldGenerateImage = true
                    imageGenerationPrompt = userInput
                }
            }
        }
        
        if !ImageGenerationLimiter.canGenerateImage(isPremium: isPremium), shouldGenerateImage, imageGenerationPrompt != nil && !imageGenerationPrompt!.isEmpty {
            // Show promo popup for upgrade to generate images
            await MainActor.run {
                isShowingPromoImageGenerationView = true
            }
        }
        
        // If isPremium, shouldGenerateImage is true, and imageGenerationPrompt can be unwrapped do image generation, otherwise do text generation
        if ImageGenerationLimiter.canGenerateImage(isPremium: isPremium), shouldGenerateImage, let imageGenerationPrompt = imageGenerationPrompt {
//            // Create, set, and save image generation AI chat
//            let imageGenerationConfirmationAIChat = Chat(context: managedContext)
//            
//            imageGenerationConfirmationAIChat.sender = Sender.ai.rawValue
//            imageGenerationConfirmationAIChat.conversation = conversation
//            imageGenerationConfirmationAIChat.date = Date()
//            imageGenerationConfirmationAIChat.text = imageGenerationConfirmationAIMessages.randomElement() ?? defaultImageGenerationConfirmationAIMessage
//            
//            try await managedContext.perform {
//                try managedContext.save()
//            }
            
            do {
                // Generate image
                try await generateImage(
                    prompt: imageGenerationPrompt,
                    authToken: authToken,
                    conversation: conversation,
                    in: managedContext)
                
                // Increment image generation limiter
                ImageGenerationLimiter.increment()
            } catch {
                // Create, set, and save image generation error AI chat
                let imageGenerationErrorAIChat = Chat(context: managedContext)
                
                imageGenerationErrorAIChat.sender = Sender.ai.rawValue
                imageGenerationErrorAIChat.conversation = conversation
                imageGenerationErrorAIChat.date = Date()
                imageGenerationErrorAIChat.text = imageGenerationErrorAIMessages.randomElement() ?? defaultImageGenerationErrorAIMessage
                
                print("Error generating image: \(error)")
                throw error
            }
        } else {
            // Generate chat text
            try await generateText(
                userTextChat: userTextChat,
                userImageChat: userImageChat,
                userImageURLChat: userImageURLChat,
                conversation: conversation,
                authToken: authToken,
                isPremium: isPremium,
                remainingUpdater: remainingUpdater,
                in: managedContext)
        }
    }
    
    private func generateText(userTextChat: Chat?, userImageChat: Chat?, userImageURLChat: Chat?, conversation: Conversation, authToken: String, isPremium: Bool, remainingUpdater: RemainingUpdater, in managedContext: NSManagedObjectContext) async throws {
        /* Defer Block */
        
        // Defer setting canGenerate to true and isLoading and isGenerating to false to ensure they are set to false when this method completes
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isGenerating = false
            }
        }
        
        /* Build Request */
        
        await MainActor.run {
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
                sender: Sender(rawValue: userTextChat.sender ?? "") ?? .user) // TODO: Is the user being the default sender here good? Should I even hsend to the server as Sender instead of the string?
        }
        
        let request = requestBuilder.build()
        
        // Create and unwrap requestString from JSONEncoded request, otherwise return
        guard let requestString = String(data: try JSONEncoder().encode(request), encoding: .utf8) else {
            // TODO: Handle errors
            print("Could not unwrap requestString in EssayChatGenerator!")
            return
        }
        
        /* Start Stream */
        
        // Get stream
        let stream = ChatWebSocketConnector.getChatStream()
        
        // Send request TODO: Handle errors here if necessary
        try await stream.send(.string(requestString))
//        PasteboardHelper.copy(String(data: try JSONEncoder().encode(request), encoding: .utf8)!)
        
        // Create firstMessage to get when the first message is processed
        var firstMessage = true
        
        // Define nullEquivalentString
        let nullEquivalentString = "null"
        
        // Define important variables to get during stream
        var fullOutput: String = ""
        var finishReason: ChatFinishReasons?
        
        var mostRecentUpdateTime: Date = Date()
        
        var tempUserImageURLChatID: Int64?
        var tempUserImageChatID: Int64?
        var tempUserTextChatID: Int64?
        var tempAIChatID: Int64?
        
        // Stream generation, updating AI chat in managed context
        do {
            for try await message in stream {
                if firstMessage {
                    // Do light haptic
                    HapticHelper.doSuccessHaptic()
                    
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
                
                // Set and save userImageURLChat's chatID as response userImageURLChatID if the response chatID is different than the temp one
                if let responseInputImageURLChat = getChatResponse.body.inputChats?.first(where: {$0.index == self.imageURLChatIndex}) {
                    if let responseInputChatIDCastInt64 = Int64(exactly: responseInputImageURLChat.chatID) {
                        if tempUserImageURLChatID != responseInputChatIDCastInt64 {
                            // Set userImageURLChat's chatID to response chatID
                            userImageURLChat?.chatID = responseInputChatIDCastInt64
                            
                            // Save to CoreData
                            do {
                                try await managedContext.perform {
                                    try managedContext.save()
                                }
                            } catch {
                                // TODO: Handle errors
                                print("Error saving to CoreData in ConversationChatGenerator... \(error)")
                            }
                            
                            // Set tempUserImageURLChatID to response chatID
                            tempUserImageURLChatID = responseInputChatIDCastInt64
                        }
                    }
                }
                
                // Set and save userImageChat's chatID as response userImageChatID if the response's chatID is different than the temp one
                if let responseInputImageChat = getChatResponse.body.inputChats?.first(where: {$0.index == self.imageChatIndex}) {
                    if let responseInputChatIDCastInt64 = Int64(exactly: responseInputImageChat.chatID) {
                        if tempUserImageChatID != responseInputChatIDCastInt64 {
                            // Set userImageChat's chatID to response's chatID
                            userImageChat?.chatID = responseInputChatIDCastInt64
                            
                            // Save to CoreData
                            do {
                                try await managedContext.perform {
                                    try managedContext.save()
                                }
                            } catch {
                                // TODO: Handle errors
                                print("Error saving to CoreData in ConversationChatGenerator... \(error)")
                            }
                            
                            // Set tempUserImageChatID to response chatID
                            tempUserImageChatID = responseInputChatIDCastInt64
                        }
                    }
                }
                
                // Set and save userTextChat's chatID as response userTextChatID if the response's chatID is different than the tmep one
                if let responseInputTextChat = getChatResponse.body.inputChats?.first(where: {$0.index == self.textChatIndex}) {
                    if let responseInputChatIDCastInt64 = Int64(exactly: responseInputTextChat.chatID) {
                        if tempUserTextChatID != responseInputChatIDCastInt64 {
                            // Set userTextChat's chatID to response's chatID
                            userTextChat?.chatID = responseInputChatIDCastInt64
                            
                            // Save to CoreData
                            do {
                                try await managedContext.perform {
                                    try managedContext.save()
                                }
                            } catch {
                                // TODO: Handle errors
                                print("Error saving to CoreData in ConversationChatGenerator... \(error)")
                            }
                            
                            // Set tempUserTextChatID to response chatID
                            tempUserTextChatID = responseInputChatIDCastInt64
                        }
                    }
                }
                
                // Set and save aiChat's chatID as response outputChatID if the response's chatID is different than the temp one
                if let outputChatID = getChatResponse.body.outputChatID, outputChatID > 0 {
                    if let outputChatIDCastInt64 = Int64(exactly: outputChatID) {
                        if tempAIChatID != outputChatIDCastInt64 {
                            // Set aiChat's text to empty and chatID to response's chatID
                            aiChat.text = ""
                            aiChat.chatID = outputChatIDCastInt64
                            
                            // Save to CoreData
                            do {
                                try await managedContext.perform {
                                    try managedContext.save()
                                }
                            } catch {
                                // TODO: Handle errors
                                print("Error saving to CoreData in ConversationChatGenerator... \(error)")
                            }
                            
                            // Set tempAIChatID to response chatID
                            tempAIChatID = aiChat.chatID
                        }
                    }
                }
                
                // Set and save conversationID as response conversationID if the response's conversationID is different than the stored one
                if let conversationID = getChatResponse.body.conversationID, conversationID > 0 {
                    if let conversationIDCastInt64 = Int64(exactly: conversationID) {
                        if conversation.conversationID != conversationIDCastInt64 {
                            // Set conversationID to response's conversationID
                            conversation.conversationID = conversationIDCastInt64
                            
                            // Save to CoreData
                            do {
                                try await managedContext.perform {
                                    try managedContext.save()
                                }
                            } catch {
                                // TODO: Handle errors
                                print("Error saving to CoreData in ConversationChatGenerator... \(error)")
                            }
                        }
                    }
                }
                
                // If the aiChat has a chatID not equal to DEFAULT_CORE_DATA_NEW_CHAT_ID, set it as the key with fullOutput as the value in generatingChats
                if Date().timeIntervalSince(mostRecentUpdateTime) >= TimeInterval(1 / UPDATES_PER_SECOND), let tempAIChatID = tempAIChatID, tempAIChatID != DEFAULT_CORE_DATA_NEW_CHAT_ID {
//                    DispatchQueue.main.async { [fullOutput] in
                    await MainActor.run { [fullOutput] in
                        self.generatingChats[tempAIChatID] = fullOutput
                    }
                    
                    mostRecentUpdateTime = Date()
//                    }
                }
            }
        } catch {
            // TODO: Handle errors
//            print("Error getting the next message in stream in ConversationChatGenerator... \(error)")
        }
        
        // Set aiChat text and remove its chatID from generatingChats on main thread
        await MainActor.run { [fullOutput] in
            // Set generatingChats value for aiChat's chatID key to nil
            generatingChats[aiChat.chatID] = nil
            
            // Set aiChat's text as fullOutput
            aiChat.text = fullOutput
            
            // Save to CoreData
            do {
                try managedContext.save()
            } catch {
                // TODO: Handle errors
                print("Error saving to CoreData in ConversationChatGenerator... \(error)")
            }
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
    
    private func generateImage(prompt: String, authToken: String, conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
        /* Defer Block */
        
        // Defer setting canGenerate to true and isLoading and isGenerating to false to ensure they are set to false when this method completes
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        // Set isLoading to true
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Create generate image request
        let giRequest = GenerateImageRequest(
            authToken: authToken,
            prompt: prompt)
        
        // Get generate image response from HTTPSConnector
        let giResponse = try await HTTPSConnector.generateImage(request: giRequest)
        
        // Ensure response has imageData, otherwise throw ChatGeneratorError imageGenerationError TODO: Make this better also for imageURL
        guard let giResponseImageData = giResponse.body.imageData else {
            throw ChatGeneratorError.imageGenerationError
        }
        
        // Try to decode image data from the base64 string imageData, otherwise throw ChatGeneratorError imageGenerationError
        guard let imageData = Data(base64Encoded: giResponseImageData) else {
            throw ChatGeneratorError.imageGenerationError
        }
        
        // Ensure an image set with its data is not nil, otherwise throw ChatGeneratorError imageGenerationError
        guard UIImage(data: imageData) != nil else {
            throw ChatGeneratorError.imageGenerationError
        }
        
        // Create and save AI Chat
        try await managedContext.perform {
            let aiChat = Chat(context: managedContext)
            
            aiChat.sender = Sender.ai.rawValue
            aiChat.conversation = conversation
            aiChat.date = Date()
            aiChat.imageData = imageData
            
            try managedContext.save()
        }
    }
    
    private func canGenerateChat(isPremium: Bool) -> Bool {
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
    
    private func previousAIChatContainsImage(conversation: Conversation, in managedContext: NSManagedObjectContext) async throws -> Bool {
        // Just check the one previous chat
        let fetchRequest: NSFetchRequest<Chat>
        fetchRequest = Chat.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Chat.date, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation.objectID)
        
        return try await managedContext.perform {
            let chats = try managedContext.fetch(fetchRequest)
            
            var aiChatFound = false
            
            // chats should contain 2 or more objects and the second should be AI and contain an image and if so return true
            if chats.count > 1, chats[1].sender == Sender.ai.rawValue, (chats[1].imageData != nil && !chats[1].imageData!.isEmpty) || (chats[1].imageURL != nil && !chats[1].imageURL!.isEmpty) {
                return true
            }
            
//            // Loop through chats
//            for i in 0..<chats.count {
//                // If aiChatFound is true and userChat is found, return false
//                if aiChatFound, chats[i].sender == Sender.user.rawValue {
//                    return false
//                }
//                
//                // If chat sender is AI, set aiChatFound to false and check if it includes an image
//                if chats[i].sender == Sender.ai.rawValue {
//                    aiChatFound = true
//                    
//                    // If any AI chat till then contains an image, return true
//                    if (chats[i].imageData != nil && !chats[i].imageData!.isEmpty) || (chats[i].imageURL != nil && !chats[i].imageURL!.isEmpty) {
//                        return true
//                    }
//                }
//            }
//            
//            // Otherwise return false, which will happen if there are no user chats
            // Otherwise return false
            return false
        }
        
    }
    
    private func getPreviousUserChatsTillPreceedingAIChatDoesNotContainImage(conversation: Conversation, in managedContext: NSManagedObjectContext) async throws -> [String] {
        // Get previous user chats till preceeding AI chat does not contain an image
        let fetchRequest: NSFetchRequest<Chat>
        fetchRequest = Chat.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Chat.date, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation.objectID)
        
        return try await managedContext.perform {
            let chats = try managedContext.fetch(fetchRequest)
            
            var userChatStrings: [String] = []
            
            var aiImageChatFoundBeforeUserChat = false
            
            // Ensure there are at least two chats, otherwise return userChatStrings
            guard chats.count > 1 else {
                return userChatStrings
            }
            
            // Loop from 1 to chats count, skipping the first chat because it's the user chat, checking if AI image is found before the previous chat is user and add it
            for i in 1..<chats.count {
                // If chat is AI and contains an image, set aiImageChatFoundBeforeUserChat to true
                if chats[i].sender == Sender.ai.rawValue {
                    if (chats[i].imageData != nil && !chats[i].imageData!.isEmpty) || (chats[i].imageURL != nil && !chats[i].imageURL!.isEmpty) {
                        aiImageChatFoundBeforeUserChat = true
                        continue
                    }
                }
                
                // If chat is User and aiImageChatFoundBeforeUserChat unwrap and ensure not empty and add text to userChatStrings and set aiImageChatFoundBeforeUserChat to false, otherwise return userChatStrings
                if chats[i].sender == Sender.user.rawValue {
                    if let chatText = chats[i].text, !chatText.isEmpty, aiImageChatFoundBeforeUserChat {
                        userChatStrings.append(chatText)
                        aiImageChatFoundBeforeUserChat = false
                        continue
                    } else {
                        return userChatStrings
                    }
                }
            }
            
            return userChatStrings
        }
    }
    
    private func promptWantsImageGeneration(authToken: String, prompt: String) async throws -> Bool {
        // Create ClassifyChatRequest
        let classifyChatRequest = ClassifyChatRequest(
            authToken: authToken,
            chat: prompt)
        
        // Get ClassifyChatResponse from HTTPSConnector and return wantsImageGeneration
        let classifyChatResponse = try await HTTPSConnector.classifyChat(request: classifyChatRequest)
        
        return classifyChatResponse.body.wantsImageGeneration
    }
    
}
