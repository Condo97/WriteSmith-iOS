//
//  ConversationViewController+ChatViewControllerDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/20/23.
//

import Foundation

extension ConversationViewController: ChatViewControllerDelegate {
    
    func popAndPushToNewConversation() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
            self.pushWith(conversation: ConversationCDHelper.appendConversation()!, animated: false)
        }
    }
    
}
