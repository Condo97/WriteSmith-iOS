//
//  ConversationItemTableViewCellDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import Foundation

extension ConversationViewController: ConversationItemTableViewCellDelegate {
    
    func didSelect(conversation: Conversation) {
        pushWith(conversation: conversation, animated: true)
    }
    
}
