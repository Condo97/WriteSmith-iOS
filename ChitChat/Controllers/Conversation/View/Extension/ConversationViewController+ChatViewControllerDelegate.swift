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
            
            Task {
                guard let newConversation = try? await ConversationCDHelper.appendConversation() else {
                    // TODO: Handle errors
                    print("Could not append conversation in ConversationViewController ChatViewControllerDelegate popAndPushToNewConversation!")
                    return
                }
                
                self.pushWith(conversation: newConversation, animated: false)
            }
        }
    }
    
}
