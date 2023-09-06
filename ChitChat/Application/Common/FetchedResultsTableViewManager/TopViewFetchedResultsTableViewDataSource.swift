//
//  TopViewFetchedResultsTableViewDataSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/1/23.
//

import CoreData
import Foundation

class TopViewFetchedResultsTableViewDataSource<Entity: NSManagedObject>: FetchedResultsTableViewDataSource<Entity> {
    
    public var topViewCellReuseIdentifier: String
    public var topViewCellDelegate: AnyObject?
    public var showTopView: Bool = true
    
    init(tableView: UITableView, managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<Entity>, cacheName: String?, topViewCellReuseIdentifier: String, topViewCellDelegate: AnyObject?, editingDelegate: FetchedResultsTableViewDataSourceEditingDelegate?, universalCellDelegate: AnyObject?, reuseIdentifier identify: @escaping (Entity, IndexPath)->String) {
        self.topViewCellReuseIdentifier = topViewCellReuseIdentifier
        self.topViewCellDelegate = topViewCellDelegate
        super.init(tableView: tableView, managedObjectContext: managedObjectContext, fetchRequest: fetchRequest, cacheName: cacheName, editingDelegate: editingDelegate, universalCellDelegate: universalCellDelegate, reuseIdentifier: identify)
    }
    
    public func getTopViewCell() -> UITableViewCell? {
        // Return the top view cell if it is showing, tableView can be unwrapped, and correct position for the cell exists
        if showTopView, let tableView = tableView, tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {
            return tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        }
        
        return nil
    }
    
    override func object(for indexPath: IndexPath) -> Entity {
        // If showTopView, decrese the section by one, otherwise just use the provided indexPath
        if showTopView {
            return super.object(for: IndexPath(row: indexPath.row, section: indexPath.section - 1))
        }
        
        return super.object(for: indexPath)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if showTopView {
            // One more section if showTopView is true
            return super.numberOfSections(in: tableView) + 1
        }
        
        return super.numberOfSections(in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TopView is shown if showTopView is true and always in the first section
        if showTopView {
            // There is always one row in the TopView section if it is showing
            if section == 0 {
                return 1
            }
            
            // The section in the super call is always -1 when showTopView is true
            return super.tableView(tableView, numberOfRowsInSection: section - 1)
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If showTopView is true then TopView is shown and sections will be shifted down by one
        if showTopView {
            // If it's the first row of the first section, dequeue topViewCell
            if indexPath.section == 0 && indexPath.row == 0 {
                let topViewCell = tableView.dequeueReusableCell(withIdentifier: topViewCellReuseIdentifier)!
                
                if var delegateTopViewCell = topViewCell as? DelegateCell {
                    delegateTopViewCell.delegate = topViewCellDelegate
                }
                
                return topViewCell
            }
            
            // The section in the super call is always -1 when showTopView is true
            return super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row, section: indexPath.section - 1))
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // If showTopView, cannot edit first row of first section
        if showTopView && indexPath.row == 0 && indexPath.section == 0 {
            return false
        }
        
        return true
    }
    
    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // If showTopView, indexPath and/or newIndexPath section will be increased by one
        if showTopView {
            var indexPathWithIncreasedSection = indexPath
            if let indexPath = indexPath {
                indexPathWithIncreasedSection = IndexPath(row: indexPath.row, section: indexPath.section + 1)
            }
            
            var newIndexPathWithIncreasedSection = newIndexPath
            if let newIndexPath = newIndexPath {
                newIndexPathWithIncreasedSection = IndexPath(row: newIndexPath.row, section: newIndexPath.section + 1)
            }
            
            super.controller(controller, didChange: anObject, at: indexPathWithIncreasedSection, for: type, newIndexPath: newIndexPathWithIncreasedSection)
        } else {
            super.controller(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
        }
    }
    
}
