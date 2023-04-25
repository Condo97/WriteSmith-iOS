//
//  ExploreViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/24/23.
//

import Foundation

class ExploreViewController: ManagedHeaderUpdatingTableViewInViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loop through the sources for each CollectionViewTableViewCellSource setting self as delegate to all ItemCellSource sources
        for tableSourceArray in sourcedTableViewManager.sources {
            for tableSource in tableSourceArray {
                if let collectionTableSource = tableSource as? CollectionTableViewCellSource {
                    for collectionSourceArray in collectionTableSource.sourcedCollectionViewManager.sources {
                        for collectionSource in collectionSourceArray {
                            if let itemSource = collectionSource as? ItemSource {
                                itemSource.delegate = self
                            }
                        }
                    }
                }
            }
        }
        
    }
    
}
