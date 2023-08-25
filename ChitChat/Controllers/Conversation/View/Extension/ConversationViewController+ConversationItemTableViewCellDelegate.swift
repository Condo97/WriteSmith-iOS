//
//  ConversationItemTableViewCellDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import Foundation

extension ConversationViewController: ConversationItemTableViewCellSourceDelegate {
    
    func didSelect(conversation: Conversation) {
        // Push to conversation view controller with conversation
        pushWith(conversation: conversation, animated: true)
    }
    
}
