//
//  UITableView+ScrollToBottomRow.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/30/23.
//

import Foundation

extension UITableView {
    
    func scrollToBottomRow(animated: Bool) {
        let lastSection = numberOfSections - 1
        let lastRow = numberOfRows(inSection: lastSection) - 1
        
        // Ensure lastSection and lastRow are not less than 0
        guard lastSection > 0 && lastRow > 0 else {
            return
        }
        
        // Do the scroll
        scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .bottom, animated: animated)
    }
    
}
