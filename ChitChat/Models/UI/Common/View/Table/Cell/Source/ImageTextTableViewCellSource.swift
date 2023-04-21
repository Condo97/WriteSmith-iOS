//
//  ImageTextTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit

class ImageTextTableViewCellSource: TableViewCellSource, SelectableTableViewCellSource {
    
    var reuseIdentifier: String = Registry.Common.View.TableView.Cell.imageText.reuseID
    
    var didSelect: (UITableView, IndexPath)->Void
    
    var image: UIImage
    var text: NSAttributedString
    
    init(didSelect: @escaping (UITableView, IndexPath)->Void, image: UIImage, text: NSAttributedString) {
        self.didSelect = didSelect
        self.image = image
        self.text = text
    }
    
}
