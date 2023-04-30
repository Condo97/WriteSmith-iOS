//
//  EssaySmallBlankHeaderSourcedTableViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/27/23.
//

import Foundation

class EssaySmallBlankHeaderSourcedTableViewManager: SmallBlankHeaderSourcedTableViewManager {
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return super.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }

        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }
    
    
    
}
