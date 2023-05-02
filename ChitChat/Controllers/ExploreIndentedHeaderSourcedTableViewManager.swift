//
//  ExploreIndentedHeaderSourcedTableViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/29/23.
//

import Foundation

class ExploreIndentedHeaderSourcedTableViewManager: IndentedHeaderSourcedTableViewManager {
    
    let DEFAULT_TOP_HEIGHT: CGFloat = 20.0
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var heightAddition: CGFloat = 0
        if section == 0 {
            heightAddition = DEFAULT_TOP_HEIGHT
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section) + heightAddition
    }
    
}
