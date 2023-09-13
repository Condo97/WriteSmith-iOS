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
    var shouldScrollOnLineUpdate = true
    var doLineUpdateScroll = false
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return cell
    }
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        super.controllerDidChangeContent(controller)
        
        // Scroll if necessary and tableView can be unwrapped
        if doLineUpdateScroll, shouldScrollOnLineUpdate, let tableView = tableView {
//            tableView.scrollToBottomRow(animated: animateScroll)
            
            doLineUpdateScroll = false
        }
    }
    
    override func showLoadingCell() {
        super.showLoadingCell()
        
        // Scroll if necessary and tableView can be unwrapped
        if doLineUpdateScroll, shouldScrollOnLineUpdate, let tableView = tableView {
//            tableView.scrollToBottomRow(animated: animateScroll)
            
            doLineUpdateScroll = false
        }
    }
    
}
