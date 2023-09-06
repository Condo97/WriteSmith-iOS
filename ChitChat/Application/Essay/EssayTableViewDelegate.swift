//
//  EssayTableViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/4/23.
//

import Foundation

class EssayTableViewDelegate: NSObject, UITableViewDelegate {
    
    /* Header */
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 10 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        section == 0 ? UIView() : nil
    }
    
    /* Footer */
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == tableView.numberOfSections - 1 ? 40 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        section == tableView.numberOfSections - 1 ? UIView() : nil
    }
    
}
