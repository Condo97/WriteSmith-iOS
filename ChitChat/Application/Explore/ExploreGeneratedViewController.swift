//
//  ExploreGeneratedViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/23/23.
//

import Foundation

class ExploreGeneratedViewController: ManagedHeaderUpdatingTableViewInViewController {
    
    // Initialization variables
    var itemSource: ItemSource?
    
    var responseText: String?
    var finishReason: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set tableView separator style and color */
        rootView.tableView.separatorStyle = .singleLine
        rootView.tableView.separatorColor = Colors.aiChatBubbleColor
        
        /* Remove middle objects in navigation stack so the back button returns to rootView https://stackoverflow.com/questions/46087057/pop-to-the-root-view-controller-when-the-navigation-bars-built-in-back-button-i */
        if let rootVC = navigationController?.viewControllers.first {
            navigationController?.viewControllers = [rootVC, self]
        }
        
    }
    
    override func setLeftMenuBarItems() {
        navigationItem.leftBarButtonItems = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Do haptic here
        HapticHelper.doLightHaptic()
    }
    
    override func updatePremium(isPremium: Bool) {
        super.updatePremium(isPremium: isPremium)
        
        sourcedTableViewManager.sources.forEach({sourceArray in
            sourceArray.forEach({source in
                if let creationSource = source as? CreationExploreTableViewCellSource {
                    creationSource.upgradeButtonIsHidden = isPremium
                }
            })
        })
        
        DispatchQueue.main.async {
            self.rootView.tableView.reloadData()
        }
    }
    
    
    class Builder<T: ExploreGeneratedViewController>: ManagedHeaderUpdatingTableViewInViewController.Builder<T> {
        
        var itemSource: ItemSource?
        
        func set(itemSource: ItemSource) -> Self {
            self.itemSource = itemSource
            return self
        }
        
        override func build(managedTableViewNibName: String) -> T {
            let controller = super.build(managedTableViewNibName: managedTableViewNibName)
            
            // Set source delegates for each CreationTableViewCellSource TODO: Can this be made more generic?
            for sourceArray in controller.sourcedTableViewManager.sources {
                for source in sourceArray {
                    if let creationSource = source as? CreationExploreTableViewCellSource {
                        // TODO: Make delegate setting generic with DelegateSource and done in superclass if that's a good idea
                        creationSource.delegate = controller
                    }
                }
            }
            
            controller.itemSource = itemSource // Wow it's so cool it recognizes controller.itemSource from that, with the associated type being ExploreGeneratedViewController because it's passed to the builder as T wow!
            
            return controller
        }
        
    }
    
}
