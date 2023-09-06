//
//  EntryEssayTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/14/23.
//

import UIKit

class EntryEssayTableViewCellSource: CellSource {
    
    var collectionViewCellReuseIdentifier: String? = nil
    var tableViewCellReuseIdentifier: String? = Registry.Essay.View.Table.Cell.entry.reuseID
    
    var cellDelegate: EssayEntryTableViewCellDelegate
    var textViewDelegate: UITextViewDelegate
    
    var useTryPlaceholderWhenLoaded: Bool
    
    init(cellDelegate: EssayEntryTableViewCellDelegate, textViewDelegate: UITextViewDelegate, useTryPlaceholderWhenLoaded: Bool) {
        self.cellDelegate = cellDelegate
        self.textViewDelegate = textViewDelegate
        self.useTryPlaceholderWhenLoaded = useTryPlaceholderWhenLoaded
    }

}
