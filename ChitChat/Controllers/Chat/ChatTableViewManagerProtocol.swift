//
//  ChatTableViewManagerProtocol.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

protocol ChatTableViewManagerProtocol: UITableViewDelegate, UITableViewDataSource {
    var chatRowSources: [[UITableViewCellSource]] { get set }
}

extension ChatTableViewManagerProtocol {
    
    func sourceFrom(indexPath: IndexPath) -> UITableViewCellSource? {
        guard chatRowSources.indices.contains(indexPath.section) else {
            return nil
        }
        
        guard chatRowSources[indexPath.section].indices.contains(indexPath.row) else {
            return nil
        }
        
        return chatRowSources[indexPath.section][indexPath.row]
    }
    
}
