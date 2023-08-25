//
//  SmallSquareCollectionViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import Foundation

class ItemExploreCollectionViewCell: UICollectionViewCell, LoadableCell, Bounceable {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    func loadWithSource(_ source: CellSource) {
        if let itemSource = source as? ItemSource {
            iconImageView.image = itemSource.iconImage
            titleLabel.text = itemSource.titleText
            descriptionTextView.text = itemSource.descriptionText
        }
    }
    
}
