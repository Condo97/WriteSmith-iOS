//
//  EntryEssayTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/14/23.
//

import UIKit

class EntryEssayTableViewCellSource: TableViewCellSource {
    
    var reuseIdentifier: String = Registry.Essay.View.Table.Cell.entry.reuseID
    
    var cellDelegate: EntryEssayTableViewCellDelegate
    var textViewDelegate: UITextViewDelegate
    
    var useTryPlaceholderWhenLoaded: Bool
    
    init(cellDelegate: EntryEssayTableViewCellDelegate, textViewDelegate: UITextViewDelegate, useTryPlaceholderWhenLoaded: Bool) {
        self.cellDelegate = cellDelegate
        self.textViewDelegate = textViewDelegate
        self.useTryPlaceholderWhenLoaded = useTryPlaceholderWhenLoaded
    }

}
