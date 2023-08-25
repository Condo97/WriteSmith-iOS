//
//  ImageTextTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit

class ImageTextTableViewCellSource: CellSource, SelectableCellSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? = Registry.Common.View.Table.Cell.imageText.reuseID
    
    var didSelect: ((UIView, IndexPath)->Void)?
    
    var image: UIImage
    var text: NSAttributedString
    
    init(didSelect: ((UIView, IndexPath)->Void)?, image: UIImage, text: NSAttributedString) {
        self.didSelect = didSelect
        self.image = image
        self.text = text
    }
    
}
