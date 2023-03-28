//
//  PaddingTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/23/23.
//

class PaddingTableViewCellSource: UITableViewCellSource {
    
    let reuseIdentifier: String = Registry.View.TableView.Chat.Cells.padding.reuseID
    
    var padding: CGFloat
    
    init() {
        self.padding = UIConstants.defaultPaddingTableViewCellSourceHeight
    }
    
    init(padding: CGFloat) {
        self.padding = padding
    }
    
}
