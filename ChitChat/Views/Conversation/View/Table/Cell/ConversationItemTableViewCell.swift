//
//  ConversationTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import CoreData
import Foundation

class ConversationItemTableViewCell: UITableViewCell, ManagedObjectCell, EditableCell {
    
    let DEFAULT_CONVERSATION_NAME_TEXT = "New Chat..."
    
    @IBOutlet weak var conversationNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var previousConversationIndicatorWidthConstraint: NSLayoutConstraint!
    
    var canEdit: Bool = true
    
    let DEFAULT_PREVIOUS_CONVERSATION_INDICATOR_WIDTH_CONSTRAINT_CONSTANT: CGFloat = 40.0
    
    func configure(managedObject: NSManagedObject) {
        // Setup with managedObject
        if let conversation = managedObject as? Conversation {
            if conversation.latestChatText == nil || conversation.latestChatText!.isEmpty {
                conversationNameLabel.text = DEFAULT_CONVERSATION_NAME_TEXT
            } else {
                conversationNameLabel.text = conversation.latestChatText
            }
            
            if let latestChatDate = conversation.latestChatDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, h:mm a"
                
                dateLabel.text = dateFormatter.string(from: latestChatDate)
            }
        }
    }
    
//    func loadWithSource(_ source: CellSource) {
//
//        // Setup with source
//        if let conversationSource = source as? ConversationItemTableViewCellSource {
//            conversationNameLabel.text = conversationSource.formattedTitle
//            dateLabel.text = conversationSource.formattedDate
//            previousConversationIndicatorWidthConstraint.constant = conversationSource.shouldShowPreviousConversationIndicator ? DEFAULT_PREVIOUS_CONVERSATION_INDICATOR_WIDTH_CONSTRAINT_CONSTANT : 0.0
//        }
//    }
    
}
