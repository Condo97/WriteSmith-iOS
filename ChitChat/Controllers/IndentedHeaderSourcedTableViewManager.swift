//
//  ExploreSourcedTableViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/24/23.
//

import Foundation

class IndentedHeaderSourcedTableViewManager: SourcedTableViewManager {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Get the view
        let view = super.tableView(tableView, viewForHeaderInSection: section)!
        
        // Ensure there is at least one subview
        guard view.subviews.count > 0 else {
            return view
        }
        
        // Add a little left padding to the header label and return view
        if let label = view.subviews[0] as? UILabel {
            label.frame = CGRect(x: label.frame.minX + 20, y: label.frame.minY, width: label.frame.size.width, height: label.frame.size.height)
        }
        
        return view
    }
    
}
