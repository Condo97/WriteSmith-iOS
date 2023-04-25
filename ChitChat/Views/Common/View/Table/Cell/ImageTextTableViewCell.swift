//
//  ImageTextTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit

class ImageTextTableViewCell: UITableViewCell, LoadableCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadWithSource(_ source: CellSource) {
        if let imageTextTableViewCellSource = source as? ImageTextTableViewCellSource {
            iconImageView.image = imageTextTableViewCellSource.image
            titleLabel.attributedText = imageTextTableViewCellSource.text
        }
    }
    
}
