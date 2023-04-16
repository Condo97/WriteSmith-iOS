//
//  SourcedTableViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

/***
 Communicates table view actions
 */
protocol SourcedTableViewManagerDelegate {
    func didSelectSourceAt(source: TableViewCellSource, indexPath: IndexPath)
}

/***
 Just holds the sources!
 */
class SourcedTableViewManager: NSObject {
    var sources: [[TableViewCellSource]] = []
    
    var delegate: SourcedTableViewManagerDelegate?
    
}

/***
 UITableViewDelegate and UITableViewDataSource
 */
extension SourcedTableViewManager: SourcedTableViewManagerProtocol {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources[section].count
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
        
        let source = sourceFrom(indexPath: indexPath)
        
        if let selectableSource = source as? SelectableTableViewCellSource {
            selectableSource.didSelect(tableView, indexPath)
        }
        
        delegate?.didSelectSourceAt(source: sourceFrom(indexPath: indexPath)!, indexPath: indexPath)
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
    
    //MARK: Non-relevant default implementations
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
}
