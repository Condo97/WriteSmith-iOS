//
//  ChatViewController+ChatSmallBlankheaderSourcedTableViewManagerDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/17/23.
//

import Foundation

extension ChatViewController: ChatSmallBlankHeaderSourcedTableViewManagerDelegate {
    
    func didFinishDisplayingAllCells() {
//        rootView.tableView.scrollToBottomUsingOffset(animated: false)
    }
    
    func didSelectSourceAt(source: CellSource, indexPath: IndexPath) {
        
    }
    
}
