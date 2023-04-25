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
    func didSelectSourceAt(source: CellSource, indexPath: IndexPath)
}

/***
 Just holds the sources!
 */
class SourcedTableViewManager: NSObject {
    // Constants
    private let DEFAULT_HEADER_HEIGHT: CGFloat = 40.0
    private let FIRST_ROW_HEADER_HIGHT_ADDITION: CGFloat = 40.0
    
    // Instance variables
    var sources: [[CellSource]] = []
    var orderedSectionHeaderTitles: [String]?
    
    var delegate: SourcedTableViewManagerDelegate?
    
}

/***
 UITableViewDelegate and UITableViewDataSource from SourcedTableViewManagerProtocol
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
        let cell = tableView.dequeueReusableCell(withIdentifier: source!.tableViewCellReuseIdentifier!, for: indexPath)
        
        if let loadableCell = cell as? LoadableCell {
            loadableCell.loadWithSource(source!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let source = sourceFrom(indexPath: indexPath)
        
        if let selectableSource = source as? SelectableCellSource {
            selectableSource.didSelect?(tableView, indexPath)
        }
        
        delegate?.didSelectSourceAt(source: source!, indexPath: indexPath)
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        // Ensure there should be section headers, otherwise return 0 as height
        guard orderedSectionHeaderTitles != nil else {
            return 0
        }
        
        // Ensure there is text for the orderedSectionHeaderTitle, otherwise return 0 as height
        guard orderedSectionHeaderTitles![section] != "" else {
            return 0
        }
        
        // Ensure there are sources in the section, otherwise return 0 as height
        guard sources[section].count > 0 else {
            return 0
        }
        
        // Return default header height plus first row header height addition for first section, then return default header height
        if section == 0 {
            return DEFAULT_HEADER_HEIGHT + FIRST_ROW_HEADER_HIGHT_ADDITION
        }
        
        return DEFAULT_HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Ensure there are sources for the section or return nil
        guard sources[section].count > 0 else {
            return nil
        }
        
        // Ensure orderedSectionHeaderTitles is not nil
        guard orderedSectionHeaderTitles != nil else {
            return nil
        }
        
        // Ensure the section is in range in orderedSectionHeaderTitles
        guard section < orderedSectionHeaderTitles!.count else {
            return nil
        }
        
        // Ensure there is text for the section in orderedSectionHeaderTitles
        guard orderedSectionHeaderTitles![section].title != "" else {
            return nil
        }
        
        // Create view using header title
        let view: UIView = UIView()
        let label = UILabel(frame: CGRect(x: 0, y: self.tableView(tableView, heightForHeaderInSection: section) - DEFAULT_HEADER_HEIGHT, width: 240, height: 30))

        label.font = UIFont(name: Constants.primaryFontNameBold, size: 24.0)
        label.text = orderedSectionHeaderTitles![section]

        view.addSubview(label)
        
        return view
    }
    
    //MARK: Non-relevant default implementations
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionFooterHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
}
