//
//  ConversationCreateTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/21/23.
//

import Foundation

class ConversationCreateTableViewCellSource: TableViewCellSource, SelectableTableViewCellSource {
    
    var reuseIdentifier: String = Registry.Conversation.View.Table.Cell.create.reuseID
    
    var didSelect: (UITableView, IndexPath)->Void
    
    init(didSelect: @escaping (UITableView, IndexPath)->Void) {
        self.didSelect = didSelect
    }
    
}
