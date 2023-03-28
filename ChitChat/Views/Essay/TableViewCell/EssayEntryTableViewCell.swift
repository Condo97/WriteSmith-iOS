//
//  EssayEntryTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/22/23.
//

import UIKit

protocol EntryEssayTableViewCellDelegate: AnyObject {
    func didPressSubmitButton(sender: Any)
}

class EssayEntryTableViewCell: UITableViewCell {

    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var delegate: EntryEssayTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func submitButton(_ sender: Any) {
        if delegate != nil {
            delegate.didPressSubmitButton(sender: sender)
        }
    }
}
