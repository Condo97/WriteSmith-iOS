//
//  UltraPurchaseTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit

class UltraPurchaseTableViewCell: UITableViewCell, LoadableTableViewCell {
    
    @IBOutlet weak var giftImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func loadWithSource(_ source: TableViewCellSource) {
        if let ultraPurchaseTableViewCellSource = source as? UltraPurchaseTableViewCellSource {
            giftImageView.image = ultraPurchaseTableViewCellSource.giftImage
            titleLabel.text = ultraPurchaseTableViewCellSource.titleText
            topTextLabel.text = ultraPurchaseTableViewCellSource.topLabelText
        }
    }

}
