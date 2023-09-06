//
//  EssayTableViewDataSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/4/23.
//

import CoreData
import Foundation

class EssayTableViewDataSource<Entity: NSManagedObject>: TopViewFetchedResultsTableViewDataSource<Entity> {
    
    var premiumCellReuseIdentifier: String
    var premiumCellDelegate: AnyObject?
    
    var loadingCellReuseIdentifier: String
    
    private var loadingCellAnimation: PulsatingDotsAnimation?
    private var showLoading: Bool = false
    
    private var showsPremiumCell: Bool = false
    
    init(tableView: UITableView, managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<Entity>, cacheName: String?, topViewCellReuseIdentifier: String, topViewCellDelegate: AnyObject?, premiumCellReuseIdentifier: String, premiumCellDelegate: AnyObject?, loadingCellReuseIdentifier: String, editingDelegate: FetchedResultsTableViewDataSourceEditingDelegate?, universalCellDelegate: AnyObject?, reuseIdentifier identify: @escaping (Entity, IndexPath) -> String) {
        self.premiumCellReuseIdentifier = premiumCellReuseIdentifier
        self.premiumCellDelegate = premiumCellDelegate
        self.loadingCellReuseIdentifier = loadingCellReuseIdentifier
        super.init(tableView: tableView, managedObjectContext: managedObjectContext, fetchRequest: fetchRequest, cacheName: cacheName, topViewCellReuseIdentifier: topViewCellReuseIdentifier, topViewCellDelegate: topViewCellDelegate, editingDelegate: editingDelegate, universalCellDelegate: universalCellDelegate, reuseIdentifier: identify)
    }
    
    public func showLoadingCell() {
        guard let tableView = self.tableView, !showLoading else { return }

        showLoading = true
        tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .none)
    }

    public func hideLoadingCell() {
        guard let tableView = self.tableView, showLoading else { return }

        showLoading = false
        loadingCellAnimation?.stop()
        loadingCellAnimation = nil
        tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .none)
    }
    
    public func showPremiumCell() {
        // Ensure showsPremiumCell is false to prevent duplicate premium cells showing, otherwise return
        guard !showsPremiumCell else {
            // TODO: Handle errors if necessary
            return
        }
        
        // Unwrap tableView and ensure there are at least two sections
        guard let tableView = tableView else {
            // TODO: Handle errors
            return
        }
        
        guard tableView.numberOfSections > 1 else {
            // TODO: Handle errors if necessary
            return
        }
        
        // Set showsPremiumCell to true
        showsPremiumCell = true
        
        // Insert row after last index in second section
        tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 1), section: 1)], with: .none)
    }
    
    public func hidePremiumCell() {
        // Ensure showsPremiumCell is true to prevent removal if there is no premium cell inserted, otherwise return
        guard showsPremiumCell else {
            // TODO: Handle errors if necessary
            return
        }
        
        // Unwrap tableView and ensure there are at least two sections and one row in the second section
        guard let tableView = tableView else {
            // TODO: Handle errors
            return
        }
        
        guard tableView.numberOfSections > 1 && tableView.numberOfRows(inSection: 1) > 0 else {
            // TODO: Handle errors
            return
        }
        
        // Set showsPremiumCell to false
        showsPremiumCell = false
        
        // Delete last row in second section
        tableView.deleteRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 1) - 1, section: 1)], with: .none)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        super.numberOfSections(in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var extraRows = 0
        if showLoading && section == 1 {
            extraRows += 1
        }
        if showsPremiumCell && section == 1 {
            extraRows += 1
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section) + extraRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showLoading && indexPath.section == 1 && indexPath.row == 0 {
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: loadingCellReuseIdentifier)!

            if var pulsatingDotsCell = loadingCell as? PulsatingDotsCell {
                if loadingCellAnimation == nil {
                    loadingCellAnimation = PulsatingDotsAnimation.createAnimation(
                        frame: pulsatingDotsCell.pulsatingDotsBounds,
                        amount: 3,
                        duration: 1,
                        color: UIColor.gray)
                    loadingCellAnimation?.start()
                }

                pulsatingDotsCell.pulsatingDotsAnimation = loadingCellAnimation
            }
            
            return loadingCell
        } else if showsPremiumCell && indexPath.section == 1 && indexPath.row == tableView.numberOfRows(inSection: 1) - 1 {
            let premiumCell = tableView.dequeueReusableCell(withIdentifier: premiumCellReuseIdentifier)!
            
            if var delegatePremiumCell = premiumCell as? DelegateCell {
                delegatePremiumCell.delegate = premiumCellDelegate
            }
            
            return premiumCell
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
}
