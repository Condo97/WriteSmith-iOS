//
//  ConversationTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import Foundation

class ConversationItemTableViewCell: UITableViewCell, LoadableCell {
    
    @IBOutlet weak var conversationNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var previousConversationIndicatorWidthConstraint: NSLayoutConstraint!
    
    let DEFAULT_PREVIOUS_CONVERSATION_INDICATOR_WIDTH_CONSTRAINT_CONSTANT: CGFloat = 40.0
    
    
    func loadWithSource(_ source: CellSource) {
        
        // Setup with source
        if let conversationSource = source as? ConversationItemTableViewCellSource {
            conversationNameLabel.text = conversationSource.formattedTitle
            dateLabel.text = conversationSource.formattedDate
            
            backgroundColor = conversationSource.backgroundColor
            
            previousConversationIndicatorWidthConstraint.constant = conversationSource.shouldShowPreviousConversationIndicator ? DEFAULT_PREVIOUS_CONVERSATION_INDICATOR_WIDTH_CONSTRAINT_CONSTANT : 0.0
        }
    }
    
}
