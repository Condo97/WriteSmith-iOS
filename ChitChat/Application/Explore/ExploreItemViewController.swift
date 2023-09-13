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
        
        /* Register for keyboard notifications */
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        /* Load Ad */
        Task {
            await InterstitialAdManager.instance.loadAd()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func setLeftMenuBarItems() {
        navigationItem.leftBarButtonItems = nil
    }
    
    @objc func tappedScreen(_ sender: Any) {
        rootView.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if rootView.tableView.contentInset.bottom == 0 {
                // Calculate extra height from tabBar
                let extraHeight = tabBarController?.tabBar.frame.size.height ?? 0
                
                // Show Keyboard
                let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight.height - extraHeight, right: 0)
                
                rootView.tableView.contentInset = insets
                rootView.tableView.scrollIndicatorInsets = insets
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if rootView.tableView.contentInset.bottom != 0 {
            // Hide Keyboard -> Reset TableView insets
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            rootView.tableView.contentInset = insets
            rootView.tableView.scrollIndicatorInsets = insets
        }
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
