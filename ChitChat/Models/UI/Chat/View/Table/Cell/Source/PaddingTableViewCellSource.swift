//
//  PaddingTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/23/23.
//

class PaddingTableViewCellSource: CellSource {
    
    var collectionViewCellReuseIdentifier: String?
    let tableViewCellReuseIdentifier: String? = Registry.Chat.View.Table.Cell.padding.reuseID
    
    var padding: CGFloat
    
    init() {
        self.padding = UIConstants.defaultPaddingTableViewCellSourceHeight
    }
    
    init(padding: CGFloat) {
        self.padding = padding
    }
    
}
