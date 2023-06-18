//
//  ChatSmallBlankHeaderSourcedTableViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/17/23.
//

import Foundation

protocol ChatSmallBlankHeaderSourcedTableViewManagerDelegate: SourcedTableViewManagerDelegate {
    func didFinishDisplayingAllCells()
}

class ChatSmallBlankHeaderSourcedTableViewManager: SmallBlankHeaderSourcedTableViewManager {
        
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        // Call didFinishLoadingAllCells on the last row of the last section
        let lastSection = tableView.numberOfSections - 1
        let lastRow = 0//tableView.numberOfRows(inSection: lastSection) - 1
        if indexPath.section == lastSection && indexPath.row == lastRow {
            if let chatSmallBlankHeaderSourcedTableViewManagerDelegate = delegate as? ChatSmallBlankHeaderSourcedTableViewManagerDelegate {
                chatSmallBlankHeaderSourcedTableViewManagerDelegate.didFinishDisplayingAllCells()
            }
        }
    }
    
}
