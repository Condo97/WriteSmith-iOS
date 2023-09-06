//
//  ChatTableViewManagerProtocol.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation
import UIKit

protocol SourcedTableViewManagerProtocol: UITableViewDelegate, UITableViewDataSource {
    var sources: [[CellSource]] { get set }
    var orderedSectionHeaderTitles: [String]? { get set }
    
    var allowsEditing: Bool { get set }
    var allowsSelection: Bool { get set }
    var hapticsEnabled: Bool { get set }
    var showsFooter: Bool { get set }
    
    var defaultHeaderHeight: CGFloat { get set }
    var firstSectionHeaderHeightAddition: CGFloat { get set }
    
    var defaultFooterHeight: CGFloat { get set }
    var lastSectionFooterHeightAddition: CGFloat { get set }
    
    var delegate: SourcedTableViewManagerDelegate? { get set }
}

extension SourcedTableViewManagerProtocol {
    
    func sourceFrom(indexPath: IndexPath) -> CellSource? {
        guard sources.indices.contains(indexPath.section) else {
            return nil
        }
        
        guard sources[indexPath.section].indices.contains(indexPath.row) else {
            return nil
        }
        
        return sources[indexPath.section][indexPath.row]
    }
    
}
