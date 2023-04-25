//
//  ConversationCreateTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/21/23.
//

import Foundation

class ConversationCreateTableViewCellSource: CellSource, SelectableCellSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? = Registry.Conversation.View.Table.Cell.create.reuseID
    
    var didSelect: ((UIView, IndexPath)->Void)?
    
    init(didSelect: @escaping (UIView, IndexPath)->Void) {
        self.didSelect = didSelect
    }
    
}
