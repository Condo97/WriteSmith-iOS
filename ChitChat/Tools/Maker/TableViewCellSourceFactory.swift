//
//  ChatTableViewCellSourceBuilder.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

import Foundation

class TableViewCellSourceFactory: Any {
    
//    /***
//     Conversation Table View Cell Source
//     */
//
//    static func makeSortedDateGroupSectionedConversationItemTableViewCellSourceArray(from conversationArray: [Conversation], indicating previousConversationToIndicate: Conversation?, delegate: ConversationItemTableViewCellSourceDelegate) async -> [[ConversationItemTableViewCellSource]] {
//        // Get sourceArray
//        var sourceArray = await makeConversationItemTableViewCellSourceArray(from: conversationArray, indicating: previousConversationToIndicate, delegate: delegate)
//
//        // Remove all where mostRecentChatDate is nil
//        sourceArray.removeAll(where: { $0.mostRecentChatDate == nil })
//
//        // Sort sourceArray
//        sourceArray.sort(by: { $0.mostRecentChatDate! > $1.mostRecentChatDate! })
//
//        return deriveDateGroupSectionedConversationItemTableViewCellSourceArray(from: sourceArray)
//    }
//
//    private static func deriveDateGroupSectionedConversationItemTableViewCellSourceArray(from conversationSourceArray: [ConversationItemTableViewCellSource]) -> [[ConversationItemTableViewCellSource]] {
//        var sectionedSourceArray: [[ConversationItemTableViewCellSource]] = []
//
//        // Add expected section count
//        DateGroupRange.allCases.forEach({ body in
//            sectionedSourceArray.append([])
//        })
//
//        print("Sectioned Source Array Count - \(sectionedSourceArray.count)")
//
//        for conversationSource in conversationSourceArray {
//            // TODO: Handle if no chats or if mostRecentChatDate is nil, currently it just doesn't add them to the source
//            if conversationSource.conversationObject.chats!.count > 0 || conversationSource.mostRecentChatDate != nil {
//                //TODO: Make sure that it is doing the local date for the startOfDay
//                let calendar = Calendar(identifier: .gregorian)
//                let daysAgo = calendar.dateComponents([.day], from: calendar.startOfDay(for: conversationSource.mostRecentChatDate!), to: calendar.startOfDay(for: Date())).day!
//
//                sectionedSourceArray[DateGroupRange.ordered.firstIndex(of: DateGroupRange.get(fromDaysAgo: daysAgo)!)!].append(conversationSource)
//            }
//        }
//
//        return sectionedSourceArray
//    }
//
//    private static func makeConversationItemTableViewCellSourceArray(from conversationArray: [Conversation], indicating previousConversationToIndicate: Conversation?, delegate: ConversationItemTableViewCellSourceDelegate) async -> [ConversationItemTableViewCellSource] {
//        var sourceArray: [ConversationItemTableViewCellSource] = []
//
//        for obj in conversationArray {
//            // Append ConversationItemTableViewCellSource with obj as conversationObject, shouldShowPreviouslyEditedIndicatorImage as true if previousConversationToIndicate is not nil and obj is equal to previousConversationToIndicate, and delegate as the delegate
//            var obj = obj // TODO: Is this bad practice? Should I just not be using the inouts ree
//            sourceArray.append(await ConversationItemTableViewCellSource(
//                conversationObject: &obj,
//                shouldShowPreviouslyEditedIndicatorImage: previousConversationToIndicate != nil && obj == previousConversationToIndicate,
//                delegate: delegate)
//            )
//        }
//
//        return sourceArray
//    }
//
//
//    /***
//     Chat Table View Cell Source
//     */
//
//    static func makeChatTableViewCellSource(from chat: Chat, isTyping: Bool, delegate: ChatTableViewCellSourceDelegate) -> ChatTableViewCellSource {
//        ChatTableViewCellSource(chat: chat, isTyping: isTyping, delegate: delegate)
//    }
//
//    static func makeChatTableViewCellSourceArray(from conversation: inout Conversation, delegate: ChatTableViewCellSourceDelegate) async throws -> [ChatTableViewCellSource]? {
//        var sourceArray: [ChatTableViewCellSource] = []
//
//        // Unwrap sortedChatArray
//        guard let sortedChatArray = try await ChatCDHelper.getOrderedChatArray(conversation: conversation.objectID) else {
//            return nil
//        }
//
//        // Get sorted chats in conversation and return sourceArray
//        for obj in sortedChatArray {
//            sourceArray.append(ChatTableViewCellSource(chat: obj, isTyping: false, delegate: delegate))
//        }
//
//        return sourceArray
//    }
    
    
//    /***
//     Essay Table View Cell Source
//     */
//    
//    static func makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObject essayObject: Essay, delegate: Any, inputAccessoryView: UIView?) -> [CellSource]? {
//        return makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObjectArray: [essayObject], delegate: delegate, inputAccessoryView: inputAccessoryView)
//    }
//    
//    static func makeArrangedPromptBodyEssayTableViewCellSourceArray(fromEssayObjectArray essayObjectArray: [Essay], delegate: Any, inputAccessoryView: UIView?) -> [CellSource]? {
//        guard let promptDelegate = delegate as? EssayPromptTableViewCellDelegate, let bodyDelegate = delegate as? EssayBodyTableViewCellDelegate else {
//            return nil
//        }
//        
//        var sourceArray: [CellSource] = []
//        
//        for obj in essayObjectArray {
//            // Append prompt first
//            sourceArray.append(makePromptEssayTableViewCellSource(fromEssayObject: obj, delegate: promptDelegate))
//            
//            // Then body
//            sourceArray.append(makeBodyEssayTableViewCellSource(fromEssayObject: obj, delegate: bodyDelegate, inputAccessoryView: inputAccessoryView))
//        }
//        
//        return sourceArray
//    }
//    
//    
//    static func makePromptEssayTableViewCellSource(fromEssayObject essayObject: Essay, delegate: EssayPromptTableViewCellDelegate) -> PromptEssayTableViewCellSource {
//        return makePromptEssayTableViewCellSourceArray(fromEssayObjectArray: [essayObject], delegate: delegate)[0]
//    }
//    
//    static func makePromptEssayTableViewCellSourceArray(fromEssayObjectArray essayObjectArray: [Essay], delegate: EssayPromptTableViewCellDelegate) -> [PromptEssayTableViewCellSource] {
//        var sourceArray: [PromptEssayTableViewCellSource] = []
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .short
//        
//        for obj in essayObjectArray {
//            sourceArray.append(PromptEssayTableViewCellSource(delegate: delegate, titleText: obj.prompt ?? "", dateText: dateFormatter.string(from: obj.date!), editedText: (obj.userEdited ? Constants.Essay.View.Table.Cell.Prompt.defaultEditedText : nil), shouldShowDeleteButton: PremiumHelper.get()))
//        }
//        
//        return sourceArray
//    }
//    
//    static func makeBodyEssayTableViewCellSource(fromEssayObject essayObject: Essay, delegate: EssayBodyTableViewCellDelegate, inputAccessoryView: UIView?) -> BodyEssayTableViewCellSource {
//        return makeBodyEssayTableViewCellSourceArray(fromEssayObjectArray: [essayObject], delegate: delegate, inputAccessoryView: inputAccessoryView)[0]
//    }
//    
//    static func makeBodyEssayTableViewCellSourceArray(fromEssayObjectArray essayObjectArray: [Essay], delegate: EssayBodyTableViewCellDelegate, inputAccessoryView: UIView?) -> [BodyEssayTableViewCellSource] {
//        var sourceArray: [BodyEssayTableViewCellSource] = []
//        
//        for obj in essayObjectArray {
//            sourceArray.append(BodyEssayTableViewCellSource(delegate: delegate, text: obj.essay ?? "", inputAccessoryView: inputAccessoryView))
//        }
//        
//        return sourceArray
//    }
    
    
    
    
    
}
