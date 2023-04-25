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
                    // Delete conversationObject from CoreData
                    ConversationCDHelper.deleteConversation(itemSource.conversationObject)
                    
                    // Delete managed row
                    managedTableView.deleteManagedRow(at: indexPath, with: .none)
                }
            }
        }
    }
    
}
