//
//  IntroInteractiveChatTableViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

/***
 Just holds the chatRowSources!
 */
class ChatTableViewManager: NSObject {
    var chatRowSources: [[UITableViewCellSource]] = []
}

/***
 UITableViewDelegate and UITableViewDataSource
 */
extension ChatTableViewManager: ChatTableViewManagerProtocol {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatRowSources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRowSources[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let source = sourceFrom(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: source!.reuseIdentifier)!
        
        if let loadableCell = cell as? LoadableTableViewCell {
            loadableCell.loadWithSource(source!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // If the current source is a PaddingTableViewCellSource, check if it is also a tieredPaddingSource and return either a height based on the tier or not otherwise return the default row height
        if let paddingSource = sourceFrom(indexPath: indexPath) as? PaddingTableViewCellSource {
            if let tieredPaddingSource = paddingSource as? TieredPaddingTableViewCellSource {
                // If the source is a tieredPaddingSource, return the correct padding for the corresponding tier
                return tieredPaddingSource.getPadding(isPremium: (UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium)))
            }
            
            // If the source is a PaddingTableViewCellSource, return the padding
            return paddingSource.padding
        }
        
        return tableView.rowHeight
    }
}
