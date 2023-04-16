//
//  ManagedTableViewInViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit

class ManagedTableViewInViewController: StackedViewController {
    
    var sourcedTableViewManager: SourcedTableViewManagerProtocol = SourcedTableViewManager()
    
    var registry: [XIB_ReuseID] = []
    
    lazy var rootView: ManagedTableViewInView! = {
        RegistryHelper.instantiateAsView(nibName: Registry.Common.View.tableViewIn, owner: self) as? ManagedTableViewInView
    }()!
    
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
    
    class Builder<T: ManagedTableViewInViewController> {
        
        let sourcedTableViewManager: SourcedTableViewManagerProtocol
        var registry: [XIB_ReuseID] = []
        
        init(sourcedTableViewManager: SourcedTableViewManagerProtocol) {
            self.sourcedTableViewManager = sourcedTableViewManager
        }
        
        func set(sources: [[TableViewCellSource]]) -> Self {
            sourcedTableViewManager.sources = sources
            return self
        }
        
        func register(_ xib_reuseID: XIB_ReuseID) -> Self {
            registry.append(xib_reuseID)
            return self
        }
        
        func build() -> T {
            let managedTableViewInViewController: T = T()
            
            // Set sourcedTableViewManager
            managedTableViewInViewController.sourcedTableViewManager = sourcedTableViewManager
            
            // Set registry
            managedTableViewInViewController.registry = registry
            
            return managedTableViewInViewController
        }
        
    }
    
}
