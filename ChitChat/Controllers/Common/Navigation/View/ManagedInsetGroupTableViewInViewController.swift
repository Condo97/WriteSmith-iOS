//
//  ManagedTableViewInViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit

class ManagedInsetGroupTableViewInViewController: UIViewController {
    
    var sourcedTableViewManager: SourcedTableViewManagerProtocol = SourcedTableViewManager()
    
    var registry: [XIB_ReuseID] = []
    
    lazy var rootView: ManagedInsetGroupedTableViewInView! = {
        RegistryHelper.instantiateAsView(nibName: Registry.Common.View.managedInsetGroupedTableViewIn, owner: self) as? ManagedInsetGroupedTableViewInView
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
    
    class Builder<T: ManagedInsetGroupTableViewInViewController> {
        
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
