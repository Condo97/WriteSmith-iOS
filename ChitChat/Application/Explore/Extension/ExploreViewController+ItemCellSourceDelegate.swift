//
//  ManagedTableViewInViewController+ItemCellSourceDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/24/23.
//

import Foundation

extension ExploreViewController: ItemCellSourceDelegate {
    
    func didSelect(source: ItemSource) {
        // Ensure source has components
        guard source.components != nil else {
            return
        }
        
        // Insert the sources into exploreItemViewController all in one array
        let exploreItemViewController = ExploreItemViewController.Builder()
            .build(itemSource: source)
        
        // Push to exploreItemViewController
        navigationController?.pushViewController(exploreItemViewController, animated: true)
    }
    
}
