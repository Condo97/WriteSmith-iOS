//
//  SourcedCollectionViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

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
    var sources: [[CellSource]] = []
    
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
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let source = sourceFrom(indexPath: indexPath)
        
        if let selectableSource = source as? SelectableCellSource {
            selectableSource.didSelect?(collectionView, indexPath)
        }
        
        delegate?.didSelectSourceAt(source: source!, indexPath: indexPath)
    }
    
}
