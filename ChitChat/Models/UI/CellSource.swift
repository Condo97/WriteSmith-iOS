//
//  UITableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

import Foundation

protocol CellSource: AnyObject {
    
    var collectionViewCellReuseIdentifier: String? { get }
    var tableViewCellReuseIdentifier: String? { get }
    
}
