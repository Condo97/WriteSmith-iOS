//
//  CollectionTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import Foundation

class CollectionTableViewCell: UITableViewCell, LoadableCell {
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: ManagedCollectionView!
    
    
    func loadWithSource(_ source: CellSource) {
        if let collectionSource = source as? CollectionTableViewCellSource {
            collectionView.manager = collectionSource.sourcedCollectionViewManager
            
            collectionSource.registry?.forEach({ xib_reuseID in
                RegistryHelper.register(xib_reuseID, to: collectionView)
            })
        }
    }
    
}
