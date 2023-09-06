//
//  SmallBlankHeaderSourcedTableViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/25/23.
//

import Foundation

class SmallBlankHeaderSourcedTableViewManager: SourcedTableViewManager {
    
    private var _blankHeaderHeight: CGFloat = 10
    var blankHeaderHeight: CGFloat {
        get {
            _blankHeaderHeight
        }
        set {
            _blankHeaderHeight = newValue
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let height = super.tableView(tableView, estimatedHeightForHeaderInSection: section)
        
        // If height is 0 from the super call return BLANK_HEADER_HEIGHT, otherwise return height
        if height <= 0 {
            return blankHeaderHeight
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
}