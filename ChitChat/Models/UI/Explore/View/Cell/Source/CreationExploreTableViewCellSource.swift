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
    var delegate: CreationExploreTableViewCellDelegate?
    
    
    convenience init(text: String) {
        self.init(text: text, delegate: nil)
    }
    
    init(text: String, delegate: CreationExploreTableViewCellDelegate?) {
        self.text = text
        self.delegate = delegate
    }
    
}
