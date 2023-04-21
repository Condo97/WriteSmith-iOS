//
//  ConversationSourcedTableViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/20/23.
//

import Foundation

class ConversationSourcedTableViewManager: SourcedTableViewManager {
    
    private let DEFAULT_HEADER_HEIGHT: CGFloat = 40.0
    private let FIRST_ROW_HEADER_HIGHT_ADDITION: CGFloat = 40.0
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Ensure section is not 0, which is the "add chat" section, otherwise return 0 as height
        guard section != 0 else {
            return 0
        }
        
        // Ensure there are sources in the section, otherwise return 0 as height
        guard sources[section].count > 0 else {
            return 0
        }
        
        // Return default header height plus first row header height addition for first section, then return default header height
        if section == 0 {
            return DEFAULT_HEADER_HEIGHT + FIRST_ROW_HEADER_HIGHT_ADDITION
        }
        
        return DEFAULT_HEADER_HEIGHT
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Ensure section is not 0, which is the "add chat" section, otherwise return nil as view
        guard section != 0 else {
            return nil
        }
        
        // Ensure there are sources for the section or return nil
        guard sources[section].count > 0 else {
            return nil
        }
        
        var view: UIView? = nil
        
        // If section - 1 for the "add chat" section is within the dateGroupRange ordered array, add a label as subview
        if section - 1 < DateGroupRange.ordered.count {
            view = UIView()
            let label = UILabel(frame: CGRect(x: 0, y: self.tableView(tableView, heightForHeaderInSection: section) - DEFAULT_HEADER_HEIGHT, width: 240, height: 30))
            
            label.font = UIFont(name: Constants.primaryFontNameBold, size: 24.0)
            label.text = DateGroupRange.ordered[section - 1].displayString
            
            view!.addSubview(label)
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Ensure section is not 0, which is the "add chat" section, otherwise return false
        guard indexPath.section != 0 else {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Handle deletions
        if editingStyle == .delete {
            
            // Get managed table view
            if let managedTableView = tableView as? ManagedTableView {
                
                // Get item source from indexPath
                if let itemSource = sourceFrom(indexPath: indexPath) as? ConversationItemTableViewCellSource {
                    // Delete conversationObject from CoreData
                    ConversationCDHelper.deleteConversation(itemSource.conversationObject)
                    
                    // Delete managed row
                    managedTableView.deleteManagedRow(at: indexPath, with: .none)
                }
            }
        }
    }
    
}
