//
//  HeadedSourcedTableViewManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

//class HeadedSourcedTableViewManager: SourcedTableViewManager {
//
//    // Constants
//    private let DEFAULT_HEADER_HEIGHT: CGFloat = 40.0
//    private let FIRST_ROW_HEADER_HIGHT_ADDITION: CGFloat = 40.0
//
//    // Instance variables
//    var orderedSectionHeaderTitles: [String]?
//
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        // Ensure there should be section headers, otherwise return 0 as height
//        guard orderedSectionHeaderTitles != nil else {
//            return 0
//        }
//
//        // Ensure there is text for the orderedSectionHeaderTitle, otherwise return 0 as height
//        guard orderedSectionHeaderTitles![section] != "" else {
//            return 0
//        }
//
//        // Ensure there are sources in the section, otherwise return 0 as height
//        guard sources[section].count > 0 else {
//            return 0
//        }
//
//        // Return default header height plus first row header height addition for first section, then return default header height
//        if section == 0 {
//            return DEFAULT_HEADER_HEIGHT + FIRST_ROW_HEADER_HIGHT_ADDITION
//        }
//
//        return DEFAULT_HEADER_HEIGHT
//    }
//
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        // Ensure there are sources for the section or return nil
//        guard sources[section].count > 0 else {
//            return nil
//        }
//
//        // Ensure orderedSectionHeaderTitles is not nil
//        guard orderedSectionHeaderTitles != nil else {
//            return nil
//        }
//
//        // Ensure the section is in range in orderedSectionHeaderTitles
//        guard section < orderedSectionHeaderTitles!.count else {
//            return nil
//        }
//
//        // Ensure there is text for the section in orderedSectionHeaderTitles
//        guard orderedSectionHeaderTitles![section].title != "" else {
//            return nil
//        }
//
//        // Create view using header title
//        let view: UIView = UIView()
//        let label = UILabel(frame: CGRect(x: 0, y: self.tableView(tableView, heightForHeaderInSection: section) - DEFAULT_HEADER_HEIGHT, width: 240, height: 30))
//
//        label.font = UIFont(name: Constants.primaryFontNameBold, size: 24.0)
//        label.text = orderedSectionHeaderTitles![section]
//
//        view.addSubview(label)
//
//        // If section - 1 for the "add chat" section is within the dateGroupRange ordered array, add a label as subview
////        if section - 1 < DateGroupRange.ordered.count {
////            view = UIView()
////            let label = UILabel(frame: CGRect(x: 0, y: self.tableView(tableView, heightForHeaderInSection: section) - DEFAULT_HEADER_HEIGHT, width: 240, height: 30))
////
////            label.font = UIFont(name: Constants.primaryFontNameBold, size: 24.0)
////            label.text = DateGroupRange.ordered[section - 1].displayString
////
////            view!.addSubview(label)
////        }
//
//        return view
//    }
//
//}
