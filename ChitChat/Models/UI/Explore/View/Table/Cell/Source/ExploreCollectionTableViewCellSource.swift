//
//  ExploreCollectionTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/29/23.
//

import Foundation

class ExploreCollectionTableViewCellSource: CollectionTableViewCellSource {
    
    override var tableViewCellReuseIdentifier: String? {
        Registry.Explore.View.Table.Cell.collection.reuseID
    }
    
    var oneRow: Bool
    
    convenience required init(sourcedCollectionViewManager: SourcedCollectionViewManager, registry: [XIB_ReuseID]?) {
        self.init(sourcedCollectionViewManager: sourcedCollectionViewManager, registry: registry, oneRow: true)
    }
    
    init(sourcedCollectionViewManager: SourcedCollectionViewManager, registry: [XIB_ReuseID]?, oneRow: Bool) {
        self.oneRow = oneRow
        
        super.init(sourcedCollectionViewManager: sourcedCollectionViewManager, registry: registry)
    }
    
}
