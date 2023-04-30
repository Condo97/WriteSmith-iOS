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
    var tableViewCellReuseIdentifier: String? {
        Registry.Common.View.Table.Cell.managedCollectionView.reuseID
    }
    
    var sourcedCollectionViewManager: SourcedCollectionViewManager
    
    var registry: [XIB_ReuseID]?
    
    convenience init(_ collectionTableViewCellSource: CollectionTableViewCellSource) {
        self.init(sourcedCollectionViewManager: collectionTableViewCellSource.sourcedCollectionViewManager, registry: collectionTableViewCellSource.registry)
    }
    
    required init(sourcedCollectionViewManager: SourcedCollectionViewManager, registry: [XIB_ReuseID]?) {
        self.sourcedCollectionViewManager = sourcedCollectionViewManager
        self.registry = registry
    }
    
    //MARK: Builder methods
    
    class Builder<T: CollectionTableViewCellSource> {
        
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
        
        func build() -> T {
            let sourcedCollectionViewManager = SourcedCollectionViewManager()
            sourcedCollectionViewManager.sources = collectionSources
            
            return T(sourcedCollectionViewManager: sourcedCollectionViewManager, registry: registry)
        }
        
    }
    
}
