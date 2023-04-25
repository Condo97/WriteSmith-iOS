//
//  CollectionTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

protocol CollectionTableViewCellSourceDelegate {
    func tapped(managedCollectionView: ManagedCollectionView, cell: UICollectionViewCell)
}

class CollectionTableViewCellSource: CellSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? = Registry.Common.View.Table.Cell.managedCollectionView.reuseID
    
    var sourcedCollectionViewManager: SourcedCollectionViewManager
    
    var registry: [XIB_ReuseID]?
    
    init(sourcedCollectionViewManager: SourcedCollectionViewManager, registry: [XIB_ReuseID]?) {
        self.sourcedCollectionViewManager = sourcedCollectionViewManager
        self.registry = registry
    }
    
    //MARK: Builder methods
    
    class Builder {
        
        var collectionSources: [[CellSource]] = []
        var registry: [XIB_ReuseID] = []
        
        func set(collectionSources: [[CellSource]]) -> Self {
            self.collectionSources = collectionSources
            return self
        }
        
        func register(collectionXIB_ReuseID: XIB_ReuseID) -> Self {
            registry.append(collectionXIB_ReuseID)
            return self
        }
        
        func build() -> CollectionTableViewCellSource {
            let sourcedCollectionViewManager = SourcedCollectionViewManager()
            sourcedCollectionViewManager.sources = collectionSources
            
            return CollectionTableViewCellSource(sourcedCollectionViewManager: sourcedCollectionViewManager, registry: registry)
        }
        
    }
    
}
