//
//  ChatViewController+ChatTableViewCellSourceDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/9/23.
//

import Foundation
import UIKit

extension ChatViewController: ChatTableViewCellSourceDelegate {
    
    func delete(source: ChatTableViewCellSource, in view: UIView, for indexPath: IndexPath) {
        // Show prompt for user to confirm deletion
        let ac = UIAlertController(
            title: "Delete Chat",
            message: "Are you sure you want to delete this chat?",
            preferredStyle: .alert)
        ac.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: {action in
                Task {
                    do {
                        // Unwrap authToken, otherwise return
                        guard let authToken = AuthHelper.get() else {
                            print("Could not unwrap AuthToken in ChatViewController ChatTableViewCellSourceDelegate!")
                            return
                        }
                        
                        // Create deleteChatRequest and delete Chat from server
                        let deleteChatRequest = DeleteChatRequest(
                            authToken: authToken,
                            chatID: Int(source.chat.chatID))
                        
                        let deleteChatStatusResponse = try await HTTPSConnector.deleteChat(request: deleteChatRequest)
                        
                        // Delete chat in core data
                        try await ChatCDHelper.deleteChat(chat: &source.chat)
                        
                        // Delete source and reload tableView
                        self.deleteFromSources(source, section: self.chatSection)
                        
                    } catch {
                        // TODO: Handle error
                        print("Could not delete chat in delete in ChatViewController ChatTableViewCellSourceDelegate... \(error)")
                    }
                    
                    
                }
            }))
        ac.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel))
        
        DispatchQueue.main.async {
            self.present(ac, animated: true)
        }
    }
    
}
