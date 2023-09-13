//
//  FetchedResultsTableViewManagerProtocol.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/27/23.
//

import CoreData
import Foundation

protocol FetchedResultsTableViewDataSourceEditingDelegate: AnyObject {
    
    func commit(editingStyle: UITableViewCell.EditingStyle, managedObject: NSManagedObject)
    
}

class FetchedResultsTableViewDataSource<Entity: NSManagedObject>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    internal weak var tableView: UITableView?
    internal weak var editingDelegate: FetchedResultsTableViewDataSourceEditingDelegate?
    internal weak var universalCellDelegate: AnyObject?
    private var fetchedResultsController: NSFetchedResultsController<Entity>
    private let identify: (Entity, IndexPath)->String
    
    init(tableView: UITableView, managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<Entity>, cacheName: String?, editingDelegate: FetchedResultsTableViewDataSourceEditingDelegate?, universalCellDelegate: AnyObject?, reuseIdentifier identify: @escaping (Entity, IndexPath)->String) {
        self.tableView = tableView
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: cacheName)
        self.editingDelegate = editingDelegate
        self.universalCellDelegate = universalCellDelegate
        self.identify = identify
        super.init()
        
        self.fetchedResultsController.delegate = self
        try? self.fetchedResultsController.performFetch()
        self.tableView?.dataSource = self
        self.tableView?.reloadData()
    }
    
    func countFetchedObjects() -> Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func object(for indexPath: IndexPath) -> Entity {
        fetchedResultsController.object(at: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let managedObject = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identify(managedObject, indexPath))!
        
        if var delegateCell = cell as? DelegateCell {
            delegateCell.delegate = universalCellDelegate
        }
        
        if let managedObjectCell = cell as? ManagedObjectCell {
            managedObjectCell.configure(managedObject: managedObject)
        }
        
        return cell
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView?.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        UIView.performWithoutAnimation {
            switch(type) {
            case .insert:
                if let newIndexPath = newIndexPath {
                    self.tableView?.insertRows(at: [newIndexPath], with: .none)
                }
            case .delete:
                if let indexPath = indexPath {
                    self.tableView?.deleteRows(at: [indexPath], with: .fade)
                }
            case .update:
                if let indexPath = indexPath, let cell = self.tableView?.cellForRow(at: indexPath) {
                    if let managedObjectCell = cell as? ManagedObjectCell, let managedObject = anObject as? Entity {
                        managedObjectCell.configure(managedObject: managedObject)
                    }
                }
            case .move:
                self.tableView?.performBatchUpdates({
                    if let indexPath = indexPath {
                        self.tableView?.deleteRows(at: [indexPath], with: .fade)
                    }
                    if let newIndexPath = newIndexPath {
                        self.tableView?.insertRows(at: [newIndexPath], with: .fade)
                    }
                })
            default:
                break
            }
            
//            DispatchQueue.main.async {
//                self.tableView?.reloadData()
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // TODO: Fix this, it is not allowed
        if let editableCell = tableView.cellForRow(at: indexPath) as? EditableCell {
            return editableCell.canEdit
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Get managedObject for cell and call commit in delegate
        let managedObject = object(for: indexPath)
        
        editingDelegate?.commit(editingStyle: editingStyle, managedObject: managedObject)
    }
    
}
