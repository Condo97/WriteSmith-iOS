//
//  ConversationTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import Foundation

protocol ConversationItemTableViewCellSourceDelegate {
    //TODO: Should this protocol be moved since it doesn't actually use the ConversationItemTableViewCell class directly, only the source?
    func didSelect(conversation: Conversation)
}

class ConversationItemTableViewCellSource: CellSource, SelectableCellSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? = Registry.Conversation.View.Table.Cell.item.reuseID
    
    var didSelect: ((UIView, IndexPath)->Void)?
    
    var conversationObject: Conversation
    var mostRecentChatDate: Date?
    
    var formattedTitle: String
    var formattedDate: String
    
    var shouldShowPreviousConversationIndicator: Bool
    
    var delegate: ConversationItemTableViewCellSourceDelegate
    
    
    convenience init(conversationObject: inout Conversation, shouldShowPreviouslyEditedIndicatorImage: Bool, delegate: ConversationItemTableViewCellSourceDelegate) async {
        // Set conversation name to last chat's text and formattedDate to last chat's date, plus store date in source for easier ordering TODO: Something better! :)
        var lastChatDate: Date?
        var lastChatText = ""
        var formattedDate = ""
        
        // Get and unwrap orderedChatArray if conversationObject has more than one chat
        do {
            if conversationObject.chats!.count > 0, let orderedChatArray = try await ChatCDHelper.getOrderedChatArray(from: &conversationObject) {
                
#warning("The last chat index may be changed if an initial chat is added!")
                // Get lastChat
                let lastChat = orderedChatArray[orderedChatArray.count - 1]
                
                // Set lastChatText
                lastChatText = lastChat.text!
                
                // Set lastChatDate and formattedDate as lastChat's date, with formattedDate dateFormat as Sep 20, 4:10 PM
                lastChatDate = lastChat.date
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, h:mm a"
                formattedDate = dateFormatter.string(from: lastChat.date!)
            }
        } catch {
            print("Error getting ordered chat array in convenience init in ConversationItemTableViewCellSource... \(error)")
        }
        
        self.init(conversationObject: conversationObject, shouldShowPreviouslyEditedIndicatorImage: shouldShowPreviouslyEditedIndicatorImage, delegate: delegate, mostRecentChatDate: lastChatDate, formattedTitle: lastChatText, formattedDate: formattedDate)
    }
    
    init(conversationObject: Conversation, shouldShowPreviouslyEditedIndicatorImage: Bool, delegate: ConversationItemTableViewCellSourceDelegate, mostRecentChatDate: Date?, formattedTitle: String, formattedDate: String) {
        self.conversationObject = conversationObject
        self.shouldShowPreviousConversationIndicator = shouldShowPreviouslyEditedIndicatorImage
        self.delegate = delegate
        self.mostRecentChatDate = mostRecentChatDate
        self.formattedTitle = formattedTitle
        self.formattedDate = formattedDate
        
        didSelect = { tableView, indexPath in
            delegate.didSelect(conversation: conversationObject)
        }
    }
    
}
