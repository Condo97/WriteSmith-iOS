//
//  SourcedCollectionViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation
import UIKit

/***
 Communicates collection view actions
 */
protocol SourcedCollectionViewManagerDelegate {
    func didSelectSourceAt(source: CellSource, indexPath: IndexPath)
}

/***
 Just holds the sources :)
 */
class SourcedCollectionViewManager: NSObject {
    //Instance variables
    var sources: [[CellSource]] = []
    
    var hapticsEnabled: Bool = true
    
    var delegate: SourcedCollectionViewManagerDelegate?
    
}

/***
 UICollectionViewDelegate and UICollectionViewDataSource from SourcedCollectionViewManagerProtocol
 */
extension SourcedCollectionViewManager: SourcedCollectionViewManagerProtocol {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sources[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let source = sourceFrom(indexPath: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: source!.collectionViewCellReuseIdentifier!, for: indexPath)
        
        if let loadableCell = cell as? LoadableCell {
            loadableCell.loadWithSource(source!)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Deselet item
        collectionView.deselectItem(at: indexPath, animated: false)
        
        // Get source from indexPath
        let source = sourceFrom(indexPath: indexPath)
        
        // If source is selectable, call didSelect
        if let selectableSource = source as? SelectableCellSource {
            selectableSource.didSelect?(collectionView, indexPath)
        }
        
        // If hapticsEnabled, do a haptic
        if hapticsEnabled {
            // Do haptic
            HapticHelper.doLightHaptic()
        }
        
        // Call delegate
        delegate?.didSelectSourceAt(source: source!, indexPath: indexPath)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return
//    }
    
}
