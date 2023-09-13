//
//  PulsatingDotsAnimationLoadableFetchedResultsTableViewDataSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/3/23.
//

import CoreData
import Foundation

class PulsatingDotsAnimationLoadableFetchedResultsTableViewDataSource<Entity: NSManagedObject>: LoadableFetchedResultsTableViewDataSource<Entity> {
    
//    let chatLoadingCellReuseIdentifier = Registry.Chat.View.Table.Cell.loading.reuseID
    var loadingCellAnimation: PulsatingDotsAnimation?
    
    init(tableView: UITableView, managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<Entity>, cacheName: String?, pulsatingDotsLoadingCellReuseIdentifier: String, editingDelegate: FetchedResultsTableViewDataSourceEditingDelegate?, universalCellDelegate: AnyObject?, reuseIdentifier identify: @escaping (Entity, IndexPath) -> String) {
        super.init(tableView: tableView, managedObjectContext: managedObjectContext, fetchRequest: fetchRequest, cacheName: cacheName, loadingCellReuseIdentifier: pulsatingDotsLoadingCellReuseIdentifier, editingDelegate: editingDelegate, universalCellDelegate: universalCellDelegate, reuseIdentifier: identify)
    }
    
    override func showLoadingCell() {
        super.showLoadingCell()
    }
    
    override func hideLoadingCell() {
        super.hideLoadingCell()
        
        // Stop animation, set dotsView to transparent, and set to nil so it can be reloaded
        self.loadingCellAnimation?.stop()
        self.loadingCellAnimation?.dotsView.alpha = 0.0
        self.loadingCellAnimation = nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Call super and if tableViewCell is ChatLoadingTableViewCell, set the loadingCellAnimation, then return
        let tableViewCell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if var pulsatingDotsCell = tableViewCell as? PulsatingDotsCell {
            // TODO: Probably want to redo this, maybe make the loadingCellAnimation pause when not on screen and stuff, I just don't want to go through testing it right now
            if loadingCellAnimation == nil {
                loadingCellAnimation = PulsatingDotsAnimation.createAnimation(
                    frame: pulsatingDotsCell.pulsatingDotsBounds,//chatLoadingTableViewCell.loadingView.bounds,
                    amount: 4,
                    duration: 1,
                    color: Colors.elementBackgroundColor)
                loadingCellAnimation?.start()
            }
            
            pulsatingDotsCell.pulsatingDotsAnimation = loadingCellAnimation
        }
        
        return tableViewCell
    }
    
}
