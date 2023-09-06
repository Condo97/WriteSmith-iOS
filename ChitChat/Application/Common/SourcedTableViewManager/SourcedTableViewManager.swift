//
//  SourcedTableViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation
import UIKit

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
    
    // Instance variables
    var sources: [[CellSource]] = [] {
        didSet {
            // If there is ever an empty inner array when setting sources, remove it
            if sources.count == 1 && sources[0].count == 0 {
                sources = []
            }
        }
    }
    var orderedSectionHeaderTitles: [String]?
    
    var allowsEditing: Bool = true
    var allowsSelection: Bool = true
    var hapticsEnabled: Bool = true
    var showsFooter: Bool = true
    
    var defaultHeaderHeight: CGFloat = 40.0
    var firstSectionHeaderHeightAddition: CGFloat = 0.0
    
    var defaultFooterHeight: CGFloat = 0.0
    var lastSectionFooterHeightAddition: CGFloat = 80.0
    
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
        // Ensure allows selection otherwise return
        guard allowsSelection else {
            return
        }
        
        // Get source from indexPath
        guard let source = sourceFrom(indexPath: indexPath) else {
            print("Couldn't unwrap source.. why?")
            return
        }
        
        // If source is selectable, call didSelect
        if let selectableSource = source as? SelectableCellSource {
            selectableSource.didSelect?(tableView, indexPath)
        }
        
        delegate?.didSelectSourceAt(source: source, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        // Ensure there should be section headers, otherwise return 0
        guard orderedSectionHeaderTitles != nil && orderedSectionHeaderTitles!.count > 0 else {
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
            return defaultHeaderHeight + firstSectionHeaderHeightAddition
        }
        
        return defaultHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        // Ensure that the footer should be shown, otherwise return 0 as height
        guard showsFooter else {
            return 0
        }
        
        // Ensure there are enough sections, otherwise return 0 as height
        guard sources.count > section else {
            return 0
        }
        
        // Ensure there are sources in the section, otherwise return 0 as height
        guard sources[section].count > 0 else {
            return 0
        }
        
        // If the section is equal to the index of the last element in the source array, return default footer height plus last section footer height addition
        if section == sources.count - 1 {
            return defaultFooterHeight + lastSectionFooterHeightAddition
        }
        
        return defaultFooterHeight
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
        guard orderedSectionHeaderTitles![section] != "" else {
            return nil
        }
        
        // Create view using header title
        let view: UIView = UIView()
        let label = UILabel(frame: CGRect(x: 0, y: self.tableView(tableView, heightForHeaderInSection: section) - defaultHeaderHeight, width: 240, height: 30))

        label.font = UIFont(name: Constants.primaryFontNameBold, size: 24.0)
        label.text = orderedSectionHeaderTitles![section]
        label.textColor = Colors.textOnBackgroundColor

        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Ensure that the footer should be shown, otherwise return 0 as height
        guard showsFooter else {
            return nil
        }
        
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Ensure allowsEditing otherwise return false
        guard allowsEditing else {
            return false
        }
        
        // Get source from indexPath
        let source = sourceFrom(indexPath: indexPath)
        
        // If source is editable return canEdit, otherwise return false
        if let editableSource = source as? EditableCellSource {
            return editableSource.canEdit
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Ensure allowsEditing otherwise return
        guard allowsEditing else {
            return
        }
        
        // Get source from indexPath
        let source = sourceFrom(indexPath: indexPath)
        
        // If source is editable, call commit
        if let editableSource = source as? EditableCellSource {
            editableSource.commit?(tableView, indexPath, editingStyle)
        }
    }
    
    //MARK: Non-relevant default implementations
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableView(tableView, estimatedHeightForFooterInSection: section)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
}
