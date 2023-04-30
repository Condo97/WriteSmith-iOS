//
//  ConversationSourcedTableViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/20/23.
//

import Foundation

class ConversationSourcedTableViewManager: SourcedTableViewManager {
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Ensure section is not 0, which is the "add chat" section, otherwise return false
        guard indexPath.section != 0 else {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Handle deletions
        if editingStyle == .delete {
            
            // Get managed table view
            if let managedTableView = tableView as? ManagedTableView {
                
                // Get item source from indexPath
                if let itemSource = sourceFrom(indexPath: indexPath) as? ConversationItemTableViewCellSource {
                    // Show alert to double check before deleting
                    let ac = UIAlertController(title: "Delete Conversation", message: "Are you sure you want to delete this conversation?", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                        // Do haptic
                        HapticHelper.doMediumHaptic()
                        
                        // Delete conversationObject from CoreData
                        ConversationCDHelper.deleteConversation(itemSource.conversationObject)
                        
                        // Delete managed row
                        managedTableView.deleteManagedRow(at: indexPath, with: .none)
                    }))
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    }))
                    
                    UIApplication.shared.topmostViewController()?.present(ac, animated: true)
                }
            }
        }
    }
    
}
