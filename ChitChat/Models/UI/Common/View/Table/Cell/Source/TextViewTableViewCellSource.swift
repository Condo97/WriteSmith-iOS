//
//  TextViewTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

class TextViewTableViewCellSource: CellSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? = Registry.Common.View.Table.Cell.textView.reuseID
    
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
}
