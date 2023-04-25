//
//  TextViewTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

class TextViewTableViewCell: UITableViewCell, LoadableCell {
    
    @IBOutlet weak var textView: UITextView!
    
    func loadWithSource(_ source: CellSource) {
        if let textViewSource = source as? TextViewTableViewCellSource {
            
        }
    }
    
}
