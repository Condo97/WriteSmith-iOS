//
//  ExploreItemViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

class ExploreItemViewController: HeaderViewController {
    
    // Instance variables
    var sourcedTableViewManager: SourcedTableViewManagerProtocol = SourcedTableViewManager()
    
    // Initialization variables
    var itemSource: ItemSource?
    var orderedSectionHeaderTitles: [String]?
    
    
    lazy var rootView: ItemExploreView = {
        let itemExploreView = RegistryHelper.instantiateAsView(nibName: Registry.Explore.View.itemExplore, owner: self) as! ItemExploreView
        itemExploreView.delegate = self
        return itemExploreView
    }()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set tableView manager */
        rootView.tableView.manager = sourcedTableViewManager
        
        /* Set headedSourcedTableViewManager orderedSectionHeaderTitles */
        sourcedTableViewManager.orderedSectionHeaderTitles = orderedSectionHeaderTitles
        
        /* Register nibs */
        RegistryHelper.register(Registry.Explore.View.Table.Cell.Item.header, to: rootView.tableView)
        RegistryHelper.register(Registry.Explore.View.Table.Cell.Item.component, to: rootView.tableView)
        
    }
    
    //MARK: Builder Functions
    
    class Builder {
        
        let sourcedTableViewManager: SourcedTableViewManagerProtocol = SourcedTableViewManager()
        var orderedSectionHeaderTitles: [String]?
        
        func set(orderedSectionHeaderTitles: [String]) -> Self {
            self.orderedSectionHeaderTitles = orderedSectionHeaderTitles
            return self
        }
        
        func build(itemSource: ItemSource) -> ExploreItemViewController {
            let exploreItemViewController = ExploreItemViewController()
            exploreItemViewController.sourcedTableViewManager = sourcedTableViewManager
            exploreItemViewController.itemSource = itemSource
            exploreItemViewController.orderedSectionHeaderTitles = orderedSectionHeaderTitles
            
            // Build sources by adding itemSource as first source followed by components in section 0
            var sources: [[CellSource]] = [[]]
            sources[0].append(itemSource)
            sources[0].append(contentsOf: itemSource.components!)
            exploreItemViewController.sourcedTableViewManager.sources = sources
            
            return exploreItemViewController
        }
        
    }
    
}
