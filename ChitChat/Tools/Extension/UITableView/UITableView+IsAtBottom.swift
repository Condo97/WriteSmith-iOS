//
//  UITableView+IsAtBottom.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

import Foundation

extension UITableView {
    
    func isAtBottom() -> Bool {
        return isAtBottom(bottomHeightOffset: 0.0)
    }
    
    func isAtBottom(bottomHeightOffset: Double) -> Bool {
        let standardBottomHeightOffset = 48.0 //TODO: - Move this
        
        return self.contentSize.height <= self.contentOffset.y + self.frame.size.height - standardBottomHeightOffset - bottomHeightOffset
    }
}
