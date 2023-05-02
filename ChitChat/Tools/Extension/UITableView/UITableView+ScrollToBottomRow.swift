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
        
        scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .bottom, animated: animated)
    }
    
}
