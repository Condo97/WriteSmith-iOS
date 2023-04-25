//
//  ManagedHeaderUpdatingTableViewInViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/24/23.
//

import Foundation

class ManagedHeaderUpdatingTableViewInViewController: HeaderViewController {
    
    var sourcedTableViewManager: SourcedTableViewManagerProtocol = SourcedTableViewManager()
    
    var registry: [XIB_ReuseID] = []
    
    var rootViewNibName: String = Registry.Common.View.managedTableViewIn
    
    
    lazy var rootView: ManagedTableViewInView = {
        return RegistryHelper.instantiateAsView(nibName: rootViewNibName, owner: self) as! ManagedTableViewInView
    }()
    
    override func loadView() {
        super.loadView()
        
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register to rootView tableView
        registry.forEach({ xib_reuseID in
            RegistryHelper.register(xib_reuseID, to: self.rootView.tableView)
        })
        
        // Set tableView manager
        rootView.tableView.manager = sourcedTableViewManager
    }
    
    //MARK: Builder Functions
    
    class Builder<T: ManagedHeaderUpdatingTableViewInViewController> {
        
        let sourcedTableViewManager: SourcedTableViewManagerProtocol
        var sources: [[CellSource]] = []
        var registry: [XIB_ReuseID] = []
        var orderedSectionHeaderTitles: [String]?
        
        init(sourcedTableViewManager: SourcedTableViewManagerProtocol) {
            self.sourcedTableViewManager = sourcedTableViewManager
        }
        
        func set(sources: [[CellSource]]) -> Self {
            self.sources = sources
            return self
        }
        
        func set(orderedSectionHeaderTitles: [String]) -> Self {
            self.orderedSectionHeaderTitles = orderedSectionHeaderTitles
            return self
        }
        
        func register(_ xib_reuseID: XIB_ReuseID) -> Self {
            registry.append(xib_reuseID)
            return self
        }
        
        func build(managedTableViewNibName: String) -> T {
            let managedTableViewInViewController: T = T()
            
            // Set sourcedTableViewManager
            managedTableViewInViewController.sourcedTableViewManager = sourcedTableViewManager
            
            // Set sources
            managedTableViewInViewController.sourcedTableViewManager.sources = sources
            
            // Set orderedSectionHeaderTitles
            managedTableViewInViewController.sourcedTableViewManager.orderedSectionHeaderTitles = orderedSectionHeaderTitles
            
            // Set rootView from managedTableViewNibName
            managedTableViewInViewController.rootViewNibName = managedTableViewNibName
            
            // Set registry
            managedTableViewInViewController.registry = registry
            
            return managedTableViewInViewController
        }
        
    }
    
}
