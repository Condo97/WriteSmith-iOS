//
//  PromptEssayTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/14/23.
//

import UIKit

class PromptEssayTableViewCellSource: TableViewCellSource {
    
    var reuseIdentifier: String = Registry.Essay.View.Table.Cell.prompt.reuseID
    
    var delegate: EssayPromptTableViewCellDelegate
    var titleText: String
    var dateText: String
    var editedText: String?
    
    init(delegate: EssayPromptTableViewCellDelegate, titleText: String, dateText: String, editedText: String?) {
        self.delegate = delegate
        self.titleText = titleText
        self.dateText = dateText
        self.editedText = editedText
    }
    
}
