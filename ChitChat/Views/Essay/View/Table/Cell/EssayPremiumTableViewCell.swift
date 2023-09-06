//
//  EssayPremiumTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/23/23.
//

import UIKit

protocol EssayPremiumTableViewCellDelegate: AnyObject {
    func didPressPremiumButton(sender: Any, cell: EssayPremiumTableViewCell)
}

class EssayPremiumTableViewCell: UITableViewCell, DelegateCell {
    
    var delegate: AnyObject?
    private var essayPremiumDelegate: EssayPremiumTableViewCellDelegate? {
        get {
            delegate as? EssayPremiumTableViewCellDelegate
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func premiumButton(_ sender: Any) {
        essayPremiumDelegate?.didPressPremiumButton(sender: sender, cell: self)
    }
    
}
