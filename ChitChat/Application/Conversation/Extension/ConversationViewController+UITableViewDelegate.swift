//
//  ConversationTableViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/1/23.
//

import Foundation

extension ConversationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // First row of the first section is new chat button
        if indexPath.section == 0 && indexPath.row == 0 {
            Task {
                do {
                    // Append and unwrap newConversation
                    guard let newConversation = try await ConversationCDHelper.appendConversation() else {
                        // TODO: Handle error
                        print("Could not append a conversation in viewWillAppear in ConversationViewController!")
                        return
                    }

                    // Do light haptic
                    HapticHelper.doLightHaptic()

                    // Push with newConversation
                    self.pushWith(conversationObjectID: newConversation, animated: true)
                } catch {
                    // TODO: Handle error
                    print("Could not append conversation in viewWillAppear in ConversationViewController... \(error)")
                }
            }
        } else {
            // If Conversation for indexPath can be unwrapped, get and push with it
            if let conversation = self.fetchedResultsTableViewDataSource?.object(for: indexPath) {
                self.pushWith(conversationObjectID: conversation.objectID, animated: true)
            }
        }
    }
    
}
