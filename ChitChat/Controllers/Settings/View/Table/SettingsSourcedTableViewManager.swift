//
//  SettingsSourcedTableViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/12/23.
//

import Foundation

class SettingsSourcedTableViewManager: SourcedTableViewManager {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ""
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Colors.userChatTextColor
        header.textLabel?.font = UIFont(name: Constants.primaryFontNameBold, size: 25)
        header.textLabel?.frame = CGRect(x: view.bounds.minX + 24, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            return 0
        }
        
        if section == 0 && UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            return 0
        }
        
        return tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            return 0
        }
        
        return tableView.estimatedSectionFooterHeight
    }
    
}
