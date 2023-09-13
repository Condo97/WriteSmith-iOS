//
//  ExploreItemViewController+ItemExploreViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/23/23.
//

import Foundation

extension ExploreItemViewController: ItemExploreViewDelegate {
    
    func generateButtonPressed(_ sender: Any) {
        // Assemble sources into query string
        //
        // Write an essay about _____
        // In the tone of _____
        
        // Get roundedButton as optional
        let roundedButton = sender as? RoundedButton
        
        // Disable roundedButton and animate activityView
        roundedButton?.startAnimatingActivityView()
        roundedButton?.isEnabled = false
        
        // Set separator and queryString
        let separator = ", "
        var queryString: String = ""
        
        // Get all sources
        for sourceArray in rootView.tableView.manager!.sources {
            for source in sourceArray {
                if let componentSource = source as? ComponentItemTableViewCellSource {
                    // Ensure componentSource value is not nil and is not blank
                    if let value = componentSource.value, value != "" {
                        queryString += "\(componentSource.promptPrefix) \(value)"
                        queryString += separator
                    }
                }
            }
        }
        
        // Remove last separator
        queryString.removeLast(separator.count)
        
//        #warning("DON'T FORGET TO DO THIS!")
//        let usePaidModel = GPTModelHelper.getCurrentChatModel() == .paid
        let currentModel = GPTModelHelper.getCurrentChatModel()
        
        // If not premium, show ad
        if !PremiumHelper.get() {
            Task {
                await InterstitialAdManager.instance.showAd(from: self)
            }
        }
        
        // Generate, build source, and push to generated on save
        ChatRequestHelper.get(inputText: queryString, conversationID: nil, model: currentModel, completion: { responseText, finishReason, conversationID, remaining in
            DispatchQueue.main.async {
                // TODO: - Save creation and stuff
                
                // Do success haptic - light haptic happens on button release
//                HapticHelper.doSuccessHaptic()
                
                // Enable roundedButton and stop animating activityView
                roundedButton?.stopAnimatingActivityView()
                roundedButton?.isEnabled = true
                
                // Push to generated view controller
                let exploreGeneratedViewController = ExploreGeneratedViewController.Builder(sourcedTableViewManager: SmallBlankHeaderSourcedTableViewManager())
                    .set(sources: [
                        [
                            CreationExploreTableViewCellSource(
                                text: responseText,
                                upgradeButtonIsHidden: PremiumHelper.get())
                        ]
                    ])
                    .set(itemSource: self.itemSource!)
                    .register(Registry.Explore.View.Table.Cell.creation)
                    .build(managedTableViewNibName: Registry.Common.View.managedTableViewIn)
                
                self.navigationController?.pushViewController(exploreGeneratedViewController, animated: true)
            }
        })
    }
    
}
