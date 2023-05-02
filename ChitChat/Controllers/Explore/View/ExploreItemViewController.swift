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
    
    var requiredComponentSources: [ComponentItemTableViewCellSource] = []
    
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
        
        /* Set required component sources and editing delegates */
        for sourceArray in sourcedTableViewManager.sources {
            for source in sourceArray {
                if let componentSource = source as? ComponentItemTableViewCellSource {
                    // Set editingDelegate to self
                    componentSource.editingDelegate = self
                    
                    // Add to required component sources array if true
                    if componentSource.required {
                        requiredComponentSources.append(componentSource)
                    }
                    
                    // Call finishedEditing on each componentSource in case there is text in any of the fields to potentially enable generate button
                    finishedEditing(source: componentSource)
                }
            }
        }
        
        /* Set tap gesture recognizer to dismiss keyboard */
        rootView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedScreen)))
        
    }
    
    override func setLeftMenuBarItems() {
        navigationItem.leftBarButtonItems = nil
    }
    
    func autoSetButtonEnabled() {
        // Set button as enabled if there are no objects in requiredComponentSources, otherwise set as not enabled
        if requiredComponentSources.count == 0 {
            // TODO: - Enable button
            DispatchQueue.main.async {
                self.rootView.generateButton.isEnabled = true
            }
        } else {
            // TODO: - Disable button
            DispatchQueue.main.async {
                self.rootView.generateButton.isEnabled = false
            }
        }
        
    }
    
    @objc func tappedScreen(_ sender: Any) {
        rootView.endEditing(true)
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
