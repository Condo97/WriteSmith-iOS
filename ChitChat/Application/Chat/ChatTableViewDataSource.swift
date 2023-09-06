//
//  ChatTableViewDataSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/4/23.
//

import CoreData
import Foundation

class ChatTableViewDataSource<Entity: NSManagedObject>: PulsatingDotsAnimationLoadableFetchedResultsTableViewDataSource<Entity> {
    
    var animateScroll = false
    var shouldScrollOnUpdate = true
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        super.controllerDidChangeContent(controller)
        
        // Scroll if necessary and tableView can be unwrapped
        if shouldScrollOnUpdate, let tableView = tableView {
            tableView.scrollToBottomRow(animated: animateScroll)
        }
    }
    
    override func showLoadingCell() {
        super.showLoadingCell()
        
        // Scroll if necessary and tableView can be unwrapped
        if shouldScrollOnUpdate, let tableView = tableView {
            tableView.scrollToBottomRow(animated: animateScroll)
        }
    }
    
}
