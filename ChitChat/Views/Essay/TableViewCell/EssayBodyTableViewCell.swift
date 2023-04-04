//
//  EssayEssayTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/22/23.
//

import UIKit

protocol EssayBodyTableViewCellDelegate: AnyObject {
    func didPressShowLess(cell: EssayBodyTableViewCell)
    func essayTextDidChange(cell: EssayBodyTableViewCell, textView: UITextView)
    func essayTextDidBeginEditing(cell: EssayBodyTableViewCell, textView: UITextView)
    func essayTextDidEndEditing(cell: EssayBodyTableViewCell, textView: UITextView)
}

class EssayBodyTableViewCell: UITableViewCell {

    @IBOutlet weak var essayTextView: UITextView!
    @IBOutlet weak var essayHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var halfRoundedView: HalfRoundedView!
    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var showLessHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var showMoreGradientView: GradientView!
    @IBOutlet weak var showMoreSolidView: UIView!
    @IBOutlet weak var copiedLabel: UILabel!
    
    var delegate: EssayBodyTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        essayTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func showLess(_ sender: Any) {
        if delegate != nil {
            delegate.didPressShowLess(cell: self)
        }
    }
}

extension EssayBodyTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate.essayTextDidChange(cell: self, textView: textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate.essayTextDidBeginEditing(cell: self, textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate.essayTextDidEndEditing(cell: self, textView: textView)
    }
}
