//
//  ManagedTableView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import Foundation

protocol ManagedTableViewTouchDelegate {
    func tappedIndexPath(_ indexPath: IndexPath, tableView: UITableView, touch: UITouch)
}

class ManagedTableView: UITableView {
    
    var touchDelegate: ManagedTableViewTouchDelegate?
    
    var manager: SourcedTableViewManagerProtocol? {
        // Automatically set the delegate and datasource when manager is set!
        didSet {
            delegate = manager
            dataSource = manager
        }
    }
    
    func appendManagedRow(bySource source: TableViewCellSource, inSection section: Int, with animation: UITableView.RowAnimation) {
        // This only works if dataSource is ChatTableViewManagerProtocol... Make this more universal TODO: -
        
        if manager != nil {
            // Do tableView updae here as there is a modification to the source array as well as the tableView
            beginUpdates()
            manager!.sources[section].append(source)
            insertRows(at: [IndexPath(row: manager!.sources[section].count - 1, section: section)], with: animation)
            endUpdates()
        }
    }
    
    func insertManagedRow(bySource source: TableViewCellSource, at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        //        tableView.beginUpdates()
        // This only works if dataSource is ChatTableViewManagerProtocol... Make this more universal TODO: -
        if manager != nil {
            beginUpdates()
            manager!.sources[indexPath.section].insert(source, at: indexPath.row)
            insertRows(at: [indexPath], with: animation)
            endUpdates()
        }
    }
    
    func deleteManagedRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        // This only works if dataSource is ChatTableViewManagerProtocol... Make this more universal TODO: -
        if manager != nil {
            beginUpdates()
            manager!.sources[indexPath.section].remove(at: indexPath.row)
            deleteRows(at: [indexPath], with: animation)
            endUpdates()
        }
    }
    
    func deleteAllManagedSources(with animation: UITableView.RowAnimation) {
        if manager != nil {
            for i in 0..<manager!.sources.count {
                for j in 0..<manager!.sources[i].count {
                    deleteManagedRow(at: IndexPath(row: j, section: i), with: animation)
                }
            }
        }
    }
    
}
