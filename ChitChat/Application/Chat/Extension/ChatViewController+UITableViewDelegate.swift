//
//  ChatTableViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/28/23.
//

import Foundation

extension ChatViewController: UITableViewDelegate {
    
    /* Header */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return !PremiumHelper.get() ? UIConstants.defaultChatTableViewHeaderHeight : UIConstants.premiumChatTableViewHeaderHeight
    }
    
    /* Footer */
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return !PremiumHelper.get() ? UIConstants.defaultChatTableViewFooterHeight : UIConstants.premiumChatTableViewFooterHeight
    }
    
    /* Scroll */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Set the fetchedResultsTableViewDataSource shouldScrollOnUpdate to false to stop scrolling on update if tableView is scrolled when a chat is generating TODO: Is this a good solution?
        if scrollView.isDragging {
            fetchedResultsTableViewDataSource?.shouldScrollOnLineUpdate = false
        }
    }
    
    /* Swipe Actions */
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {action, sourceView, completionHandler in
            if let chat = self.fetchedResultsTableViewDataSource?.object(for: indexPath) as? Chat {
                self.deleteChat(chat)
            }
            
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "xmark")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}
