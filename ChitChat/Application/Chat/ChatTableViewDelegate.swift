//
//  ChatTableViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/28/23.
//

import Foundation

class ChatTableViewDelegate: NSObject, UITableViewDelegate {
    
    /* Header */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    /* Footer */
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return !PremiumHelper.get() ? UIConstants.defaultPaddingTableViewCellSourceHeight : UIConstants.premiumPaddingTableViewCellSourceHeight
    }
    
}
