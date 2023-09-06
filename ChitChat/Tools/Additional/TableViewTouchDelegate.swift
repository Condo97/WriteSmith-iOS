//
//  TableViewTouchDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/28/23.
//

import Foundation

protocol TableViewTouchDelegate {
    func tappedIndexPath(_ indexPath: IndexPath, tableView: UITableView, touch: UITouch)
}
