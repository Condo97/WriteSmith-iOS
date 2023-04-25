//
//  ManagedCollectionView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/24/23.
//

import Foundation

class ManagedCollectionView: UICollectionView {
    
    var manager: SourcedCollectionViewManagerProtocol? {
        // Automatically set the delegate and datasource when manager is set!
        didSet {
            delegate = manager
            dataSource = manager
        }
    }
    
    func appendManagedItem(bySource source: CellSource, inSection section: Int) {
        // This only works if dataSource is ChatTableViewManagerProtocol... Make this more universal TODO: -
        
        if manager != nil {
            // Do tableView update here as there is a modification to the source array as well as the tableView
            manager!.sources[section].append(source)
            insertItems(at: [IndexPath(row: manager!.sources[section].count - 1, section: section)])
        }
    }
    
    func insertManagedItem(bySource source: CellSource, at indexPath: IndexPath) {
        //        tableView.beginUpdates()
        // This only works if dataSource is ChatTableViewManagerProtocol... Make this more universal TODO: -
        if manager != nil {
            manager!.sources[indexPath.section].insert(source, at: indexPath.row)
            insertItems(at: [indexPath])
        }
    }
    
    func deleteManagedItem(at indexPath: IndexPath) {
        // This only works if dataSource is ChatTableViewManagerProtocol... Make this more universal TODO: -
        if manager != nil {
            manager!.sources[indexPath.section].remove(at: indexPath.row)
            deleteItems(at: [indexPath])
        }
    }
    
    func deleteAllManagedSources() {
        if manager != nil {
            for i in 0..<manager!.sources.count {
                for j in 0..<manager!.sources[i].count {
                    deleteManagedItem(at: IndexPath(row: j, section: i))
                }
            }
        }
    }
    
}
