//
//  ManagedTableView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import Foundation

class ManagedTableView: UITableView {
    
    var touchDelegate: TableViewTouchDelegate?
    
    var manager: SourcedTableViewManagerProtocol? {
        // Automatically set the delegate and datasource when manager is set!
        didSet {
            delegate = manager
            dataSource = manager
        }
    }
    
//    func appendManagedRow(bySource source: CellSource, inSection section: Int, with animation: UITableView.RowAnimation) {
//        // This only works if dataSource is ChatTableViewManagerProtocol... Make this more universal TODO: -
//        
//        if manager != nil {
//            // Do tableView update here as there is a modification to the source array as well as the tableView
//            beginUpdates()
//            manager!.sources[section].append(source)
//            insertRows(at: [IndexPath(row: manager!.sources[section].count - 1, section: section)], with: animation)
//            endUpdates()
//        }
//    }
//    
//    func appendManagedSections(bySources sources: [[CellSource]], with animation: UITableView.RowAnimation) {
//        
//        if manager != nil {
//            // Get section offset for preexisting sections
//            let sectionOffset = manager!.sources.count
//            
//            // Get all indexPaths for sources
//            var indexPaths: [IndexPath] = []
//            for i in 0..<sources.count {
//                for j in 0..<sources[i].count {
//                    indexPaths.append(IndexPath(row: j, section: i + sectionOffset))
//                }
//                
//                // Append each source array to sources
//                manager!.sources.append(sources[i])
//            }
//            
//            // Insert the sections and rows for indexPaths in tableView
//            beginUpdates()
//            insertSections(IndexSet(integersIn: sectionOffset..<manager!.sources.count), with: animation)
//            insertRows(at: indexPaths, with: animation)
//            endUpdates()
//        }
//    }
//    
//    func insertManagedRow(bySource source: CellSource, at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
//        //        tableView.beginUpdates()
//        // This only works if dataSource is ChatTableViewManagerProtocol... Make this more universal TODO: -
//        if manager != nil {
//            beginUpdates()
//            manager!.sources[indexPath.section].insert(source, at: indexPath.row)
//            insertRows(at: [indexPath], with: animation)
//            endUpdates()
//        }
//    }
//    
//    func deleteManagedRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
//        // This only works if dataSource is ChatTableViewManagerProtocol... Make this more universal TODO: -
//        if manager != nil {
//            beginUpdates()
//            manager!.sources[indexPath.section].remove(at: indexPath.row)
//            deleteRows(at: [indexPath], with: animation)
//            endUpdates()
//        }
//    }
//    
//    func deleteAllManagedSources(with animation: UITableView.RowAnimation) {
//        if manager != nil {
//            // Get all indexPaths for sources
//            var indexPaths: [IndexPath] = []
//            for i in 0..<manager!.sources.count {
//                for j in 0..<manager!.sources[i].count {
////                    deleteManagedRow(at: IndexPath(row: j, section: i), with: animation)
//                    indexPaths.append(IndexPath(row: j, section: i))
//                }
//            }
//            
//            // Get sections indexSet
//            let sections: IndexSet = IndexSet(integersIn: 0..<manager!.sources.count)
//            
//            beginUpdates()
//            manager!.sources = []
//            deleteRows(at: indexPaths, with: animation)
//            deleteSections(sections, with: animation)
//            endUpdates()
//        }
//    }
    
}
