//
//  PaddingTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/23/23.
//

class PaddingTableViewCellSource: TableViewCellSource {
    
    let reuseIdentifier: String = Registry.Chat.View.TableView.Cell.padding.reuseID
    
    var padding: CGFloat
    
    init() {
        self.padding = UIConstants.defaultPaddingTableViewCellSourceHeight
    }
    
    init(padding: CGFloat) {
        self.padding = padding
    }
    
}
