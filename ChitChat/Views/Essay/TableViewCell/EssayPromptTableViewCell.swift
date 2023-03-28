//
//  EssayTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/21/23.
//

import UIKit

protocol EssayPromptTableViewCellDelegate: AnyObject {
    func didPressCopyText(cell: EssayPromptTableViewCell)
    func didPressShare(cell: EssayPromptTableViewCell)
    func didPressDeleteRow(cell: EssayPromptTableViewCell)
}

class EssayPromptTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var editedLabel: UILabel!
    @IBOutlet weak var halfRoundedView: HalfRoundedView!
    @IBOutlet weak var deleteButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareButtonWidthConstraint: NSLayoutConstraint!
    
    var delegate: EssayPromptTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func copyText(_ sender: Any) {
        delegate.didPressCopyText(cell: self)
    }
    
    @IBAction func share(_ sender: Any) {
        delegate.didPressShare(cell: self)
    }
    
    @IBAction func deleteRow(_ sender: Any) {
        delegate.didPressDeleteRow(cell: self)
    }
}
