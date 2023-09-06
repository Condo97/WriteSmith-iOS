//
//  ConversationViewController+FetchedResultsTableViewDataSourceEditingDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/5/23.
//

import CoreData
import Foundation

extension ConversationViewController: FetchedResultsTableViewDataSourceEditingDelegate {
    
    func commit(editingStyle: UITableViewCell.EditingStyle, managedObject: NSManagedObject) {
        if editingStyle == .delete {
            if let conversation = managedObject as? Conversation {
                // Show alert to double check before deleting
                let ac = UIAlertController(title: "Delete Conversation", message: "Are you sure you want to delete this conversation?", preferredStyle: .alert)
                ac.view.tintColor = Colors.alertTintColor
                ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                    // Do haptic
                    HapticHelper.doMediumHaptic()
                    
                    // Delete conversationObject from CoreData
                    Task {
                        do {
                            try await ConversationCDHelper.deleteConversation(conversationObjectID: conversation.objectID)
                        } catch {
                            // TODO: Handle deletion error
                            print("Could not delete conversation in tableView in ConversationSourcedTableViewManager SourcedTalbeViewManager tableViewForRowAtIndexPath")
                        }
                    }
                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                }))
                
                self.present(ac, animated: true)
            }
        }
    }
    
}
