//
//  LoadableFetchedResultsTableViewDataSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/28/23.
//

import CoreData
import Foundation

class LoadableFetchedResultsTableViewDataSource<Entity: NSManagedObject>: FetchedResultsTableViewDataSource<Entity> {
    
    var loadingCellReuseIdentifier: String
    var loadingOnTop: Bool = true
    
    private var showLoading: Bool = false
    
    init(tableView: UITableView, managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<Entity>, cacheName: String?, loadingCellReuseIdentifier: String, editingDelegate: FetchedResultsTableViewDataSourceEditingDelegate?, universalCellDelegate: AnyObject?, reuseIdentifier identify: @escaping (Entity, IndexPath)->String) {
        self.loadingCellReuseIdentifier = loadingCellReuseIdentifier
        super.init(tableView: tableView, managedObjectContext: managedObjectContext, fetchRequest: fetchRequest, cacheName: cacheName, editingDelegate: editingDelegate, universalCellDelegate: universalCellDelegate, reuseIdentifier: identify)
    }
    
    public func getLoadingCell() -> UITableViewCell? {
        // If showLoading is true, tableView can be unwrapped, and there is at least one section and row for the first section in tableView, return the last cell in the first section
        if showLoading, let tableView = tableView, tableView.numberOfSections > 0, tableView.numberOfRows(inSection: 0) > 0 {
            return tableView.cellForRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0))
        }
        
        return nil
    }
    
    public func showLoadingCell() {
        // Ensure showLoading is false, otherwise return and don't insert since the loading cell is inserted
        guard !showLoading else {
            // TODO: Handle errors if necessary
            return
        }
        
        // Unwrap tableView and ensure there is at least one section, otherwise return
        guard let tableView = tableView else {
            // TODO: Handle errors
            return
        }
        
        guard tableView.numberOfSections > 0 else {
            // TODO: Handle errors if necessary
            return
        }
        
        // Set showLoading to true for the tableView to account for it accordingly
        showLoading = true
        
        // Insert loading cell at first row in the first section
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    public func hideLoadingCell() {
        // Ensure showLoading is true, otherwise return and don't delete since the loading cell is not inserted
        guard showLoading else {
            // TODO: Handle errors if necessary
            return
        }
        
        // Unwrap tableView and ensure there is at least one section and row in that section, otherwise return
        guard let tableView = tableView else {
            // TODO: Handle errors
            return
        }
        
        guard tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 else {
            // TODO: Handle errors if necessary
            return
        }
        
        // Set showLoading to false for the tableView to account for it accordingly
        showLoading = false
        
        // Remove loading cell at the first row in the first section
        tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    public func isShowingLoading() -> Bool {
        showLoading
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If showLoading is true, add an extra cell to the count of the first section
        if showLoading && section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: section) + 1
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If showLoading is true and it's the first cell in the first section, dequeue with loadingCellReuseIdentifier and if ManagedObjectCell configure
        if showLoading && indexPath.section == 0 && indexPath.row == 0 {
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: loadingCellReuseIdentifier)!
            
            return loadingCell
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // If showLoading, indexPath and/or newIndexPath row will be decreased by one
        if showLoading {
            var indexPathWithIncreasedSection = indexPath
            if let indexPath = indexPath {
                indexPathWithIncreasedSection = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            }

            var newIndexPathWithIncreasedSection = newIndexPath
            if let newIndexPath = newIndexPath {
                newIndexPathWithIncreasedSection = IndexPath(row: newIndexPath.row, section: newIndexPath.section)
            }

            super.controller(controller, didChange: anObject, at: indexPathWithIncreasedSection, for: type, newIndexPath: newIndexPathWithIncreasedSection)
        } else {
            super.controller(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
        }
    }
    
}
