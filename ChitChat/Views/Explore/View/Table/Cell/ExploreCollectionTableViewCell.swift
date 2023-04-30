//
//  ExploreCollectionTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/29/23.
//

import Foundation

class ExploreCollectionTableViewCell: CollectionTableViewCell {
    
    let COLUMNS_FOR_MULTIPLE_ROW_COLLECTION_VIEW: Int = 2
    
    
    override func loadWithSource(_ source: CellSource) {
        super.loadWithSource(source)
        
        if let exploreCollectionSource = source as? ExploreCollectionTableViewCellSource {
            if exploreCollectionSource.oneRow {
                collectionViewHeightConstraint.constant = collectionViewFlowLayout.itemSize.height
                collectionViewFlowLayout.scrollDirection = .horizontal
            } else {
                collectionViewHeightConstraint.constant = CGFloat(collectionView.manager!.sources[0].count / COLUMNS_FOR_MULTIPLE_ROW_COLLECTION_VIEW + 1) * collectionViewFlowLayout.itemSize.height + 20
                collectionViewFlowLayout.scrollDirection = .vertical
            }
        }
    }
    
}
