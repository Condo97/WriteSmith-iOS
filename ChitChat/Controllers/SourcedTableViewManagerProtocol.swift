//
//  ChatTableViewManagerProtocol.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

protocol SourcedTableViewManagerProtocol: UITableViewDelegate, UITableViewDataSource {
    var sources: [[TableViewCellSource]] { get set }
    
    var delegate: SourcedTableViewManagerDelegate? { get set }
}

extension SourcedTableViewManagerProtocol {
    
    func sourceFrom(indexPath: IndexPath) -> TableViewCellSource? {
        guard sources.indices.contains(indexPath.section) else {
            return nil
        }
        
        guard sources[indexPath.section].indices.contains(indexPath.row) else {
            return nil
        }
        
        return sources[indexPath.section][indexPath.row]
    }
    
}
