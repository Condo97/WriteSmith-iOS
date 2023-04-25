//
//  SourcedCollectionViewManagerProtocol.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

protocol SourcedCollectionViewManagerProtocol: UICollectionViewDelegate, UICollectionViewDataSource {
    var sources: [[CellSource]] { get set }
    
    var delegate: SourcedCollectionViewManagerDelegate? { get set }
}

extension SourcedCollectionViewManagerProtocol {
    
    func sourceFrom(indexPath: IndexPath) -> CellSource? {
        guard sources.indices.contains(indexPath.section) else {
            return nil
        }
        
        guard sources[indexPath.section].indices.contains(indexPath.row) else {
            return nil
        }
        
        return sources[indexPath.section][indexPath.row]
    }
    
}
