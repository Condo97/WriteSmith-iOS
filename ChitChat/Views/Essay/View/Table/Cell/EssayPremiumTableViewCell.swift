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

class EssayPremiumTableViewCell: UITableViewCell, LoadableTableViewCell {
    
    var delegate: EssayPremiumTableViewCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func premiumButton(_ sender: Any) {
        delegate.didPressPremiumButton(sender: sender, cell: self)
    }
    
    func loadWithSource(_ source: TableViewCellSource) {
        if let premiumSource = source as? PremiumEssayTableViewCellSource {
            delegate = premiumSource.delegate
        }
    }
    
}
