//
//  HeaderItemExploreTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

class HeaderItemExploreTableViewCell: UITableViewCell, LoadableCell {
    
    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func loadWithSource(_ source: CellSource) {
        // Use the same source as the item in the collection view!
        if let itemSource = source as? ItemSource {
            iconImageView.image = itemSource.iconImage
            titleLabel.text = itemSource.titleText
            descriptionLabel.text = itemSource.descriptionText
        }
    }
    
}
