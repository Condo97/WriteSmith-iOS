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
    
    let smallScreenSize = 380.0
    let medScreenSize = 400.0
    let maxScreenSizeToUseMultiRowSectionInsets = 400.0
    
    var originalSectionInsets: UIEdgeInsets?
    var multiRowSectionInsets: UIEdgeInsets? {
        let screenWidth = UIScreen.main.bounds.width
        
        if screenWidth < smallScreenSize {
            return UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
        }
        
        if screenWidth < medScreenSize {
            return UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 20.0)
        }
        
        return originalSectionInsets
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
