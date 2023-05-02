//
//  ExploreViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/24/23.
//

import Foundation

class ExploreViewController: ManagedHeaderUpdatingTableViewInViewController {
    
    private let HDR_POP_AMOUNT: Int = 1 // The amount of objects to remove from the leading side of persistentHeaders when converting to orderedSectionHeaderTitles.. Currently removes, "Suggested" item
    
    var persistentSources: [[CellSource]]?
    var persistentHeaders: [String]?
    
    var topCollectionSourcedCollectionViewManager: SourcedCollectionViewManagerProtocol = SourcedCollectionViewManager()
    
    lazy final var topCollectionSources: [[CellSource]] = {
        /* Append ordered section header titles as button collection view cell sources and return inside an array */
        var buttonSources: [ButtonCollectionViewCellSource] = []
        
        // Set all button sources in topCollectionSources to false
        func setAllButtonSourcesInTopCollectionSourcesToFalse() {
            for collectionSourceArray in self.topCollectionSources {
                for collectionSource in collectionSourceArray {
                    if let buttonSource = collectionSource as? ButtonCollectionViewCellSource {
                        buttonSource.selected = false
                    }
                }
            }
        }
        
        // Set first source as "All"
        buttonSources.append(ButtonCollectionViewCellSource(buttonTitle: "All", selected: true, didSelectSource: { source, indexPath in
            // Set all sources selected to false
            setAllButtonSourcesInTopCollectionSourcesToFalse()
            
            // Set selected in source to true
            source.selected = true
            
            // Change collectionView to filter by nil
            self.filterTableViewCollectionViews(section: nil)
            
            // Reload collectionView
            if let exploreView = self.rootView as? ExploreView {
                exploreView.topCollectionView.reloadData()
            }
        }))
        
        // Set the rest of the sources
        for i in HDR_POP_AMOUNT..<sourcedTableViewManager.orderedSectionHeaderTitles!.count {
            let headerTitle = sourcedTableViewManager.orderedSectionHeaderTitles![i]
            buttonSources.append(ButtonCollectionViewCellSource(buttonTitle: headerTitle, selected: false, didSelectSource: { source, indexPath in
                // Set all sources selected to false
                setAllButtonSourcesInTopCollectionSourcesToFalse()
                
                // Set selected in source to true
                source.selected = true
                
                // Change collectionView to filter by the section
                self.filterTableViewCollectionViews(section: indexPath.item)
                
                // Reload collectionView
                if let exploreView = self.rootView as? ExploreView {
                    exploreView.topCollectionView.reloadData()
                }
            }))
        }
        
        return [buttonSources]
    }()
    
    override func loadView() {
        super.loadView()
        
        /* Set persistentSources and persistentHeaders */
        persistentSources = sourcedTableViewManager.sources
        persistentHeaders = sourcedTableViewManager.orderedSectionHeaderTitles
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set topCollectionView Manager and Register Nibs to topCollectionView */
        if let exploreView = rootView as? ExploreView {
            exploreView.topCollectionView.manager = topCollectionSourcedCollectionViewManager
            
            RegistryHelper.register(Registry.Common.View.Collection.Cell.roundedViewLabelCollectionViewCell, to: exploreView.topCollectionView)
        }
        
        /* Set topCollectionSourcedCollectionViewManager sources */
        topCollectionSourcedCollectionViewManager.sources = topCollectionSources
        
        /* Loop through the sources for each CollectionViewTableViewCellSource setting self as delegate to all ItemCellSource sources */
        for tableSourceArray in sourcedTableViewManager.sources {
            for tableSource in tableSourceArray {
                if let collectionTableSource = tableSource as? ExploreCollectionTableViewCellSource {
                    for collectionSourceArray in collectionTableSource.sourcedCollectionViewManager.sources {
                        for collectionSource in collectionSourceArray {
                            if let itemSource = collectionSource as? ItemSource {
                                itemSource.delegate = self
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    override func setLeftMenuBarItems() {
        super.setLeftMenuBarItems()
        
        // Remove first left bar button item if it is there
        if navigationItem.leftBarButtonItems!.count > 0 {
            navigationItem.leftBarButtonItems!.remove(at: 0)
        }
        
        //TODO: Swap this with the three lines, since the gear is shown on more views
        // Insert gear button with settingsPressed target as first left bar button item
        let settingsMenuBarButtonImage = UIImage(systemName: "gear")
        let settingsMenuBarButton = UIButton(type: .custom)
        settingsMenuBarButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 28.0)
        settingsMenuBarButton.tintColor = Colors.elementTextColor
        settingsMenuBarButton.setBackgroundImage(settingsMenuBarButtonImage, for: .normal)
        settingsMenuBarButton.addTarget(self, action: #selector(settingsPressed), for: .touchUpInside)
        let settingsMenuBarItem = UIBarButtonItem(customView: settingsMenuBarButton)
        
        navigationItem.leftBarButtonItems!.insert(settingsMenuBarItem, at: 0)
    }
    
    @objc func settingsPressed() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Push to settings TODO: Move this!
        navigationController?.pushViewController(SettingsPresentationSpecification().viewController, animated: true)
    }
    
    func filterTableViewCollectionViews(section: Int?) {
        DispatchQueue.main.async {
            // Perform without animation
            UIView.performWithoutAnimation {
                // Clear tableView
                self.rootView.tableView.deleteAllManagedSources(with: .none)
                
                // If section is not nil and > 0 and < topCollectionSources.count set to collection view cell with vertical collection view with just the sources from that section, otherwise set tableView to show all TODO: - Is it fine to have that 0 there?
                if section != nil && section! > 0 && section! < self.topCollectionSources[0].count {
                    // Append the exploreCollectionTableViewCellSource for the section TODO: - Make this better
                    self.rootView.tableView.appendManagedSections(bySources: [[ExploreCollectionTableViewCellSource(self.persistentSources![section! - 1 + self.HDR_POP_AMOUNT][0] as! ExploreCollectionTableViewCellSource)]], with: .none)
                    
                    // Set new collectionViewCellSource as not one row
                    // Set section header as the only section header in manager's orderedSectionHeaderTitles
                    if let manager = self.rootView.tableView.manager {
                        // Set new collectionViewCellSource as not one row
                        (manager.sources[0][0] as! ExploreCollectionTableViewCellSource).oneRow = false
                        
                        // Set the header for the section as the only header in manager's orderedSectionHeaderTitles
                        manager.orderedSectionHeaderTitles = [self.persistentHeaders![section! - 1 + self.HDR_POP_AMOUNT]]
                    }
                    
                    self.rootView.tableView.reloadData()
                } else {
                    self.rootView.tableView.manager?.orderedSectionHeaderTitles = self.persistentHeaders
                    self.rootView.tableView.appendManagedSections(bySources: self.persistentSources!, with: .none)
                }
            }
        }
    }
    
    
}
