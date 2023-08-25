//
//  CreationTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/25/23.
//

import Foundation

class CreationExploreTableViewCellSource: CellSource, DelegateSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? = Registry.Explore.View.Table.Cell.creation.reuseID
    
    var text: String
    var upgradeButtonIsHidden: Bool
    
    var delegate: CreationExploreTableViewCellDelegate?
    
    
    convenience init(text: String, upgradeButtonIsHidden: Bool) {
        self.init(text: text, delegate: nil, upgradeButtonIsHidden: upgradeButtonIsHidden)
    }
    
    init(text: String, delegate: CreationExploreTableViewCellDelegate?, upgradeButtonIsHidden: Bool) {
        self.text = text
        self.delegate = delegate
        self.upgradeButtonIsHidden = upgradeButtonIsHidden
    }
    
}
