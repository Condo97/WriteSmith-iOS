//
//  SelectableTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/13/23.
//

import Foundation

protocol SelectableTableViewCellSource: TableViewCellSource {
    
    var didSelect: (UITableView, IndexPath)->Void { get set }
    
}
