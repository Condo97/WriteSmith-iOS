//
//  EssaySourcedTableViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/14/23.
//

import UIKit

class EssaySourcedTableViewManager: SourcedTableViewManager {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        
        return nil
    }
    
}
