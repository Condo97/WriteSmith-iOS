//
//  ExploreCollectionViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/22/23.
//

import Foundation

protocol ItemCellSourceDelegate {
    func didSelect(source: ItemSource)
}

class ItemSource: CellSource, SelectableCellSource {
    
    var collectionViewCellReuseIdentifier: String? = Registry.Explore.View.Collection.Cell.item.reuseID
    var tableViewCellReuseIdentifier: String? = Registry.Explore.View.Table.Cell.Item.header.reuseID
    
    var didSelect: ((UIView, IndexPath)->Void)? // Action called on cell selection
    
    var iconImage: UIImage // Displayed icon image
    var titleText: String // Displayed title text
    var descriptionText: String // Displayed description text
    
    var behavior: String? // System text that the creation will specify when generating the chat
    
    var components: [ComponentItemTableViewCellSource]? // Components to be in the detail view
    
    var delegate: ItemCellSourceDelegate? // Delegate to handle selection
    
    
    convenience init(iconImage: UIImage, titleText: String, descriptionText: String, components: [ComponentItemTableViewCellSource]) {
        self.init(iconImage: iconImage, titleText: titleText, descriptionText: descriptionText, behavior: nil, components: components)
    }
    
    convenience init(iconImage: UIImage, titleText: String, descriptionText: String, behavior: String?, components: [ComponentItemTableViewCellSource]) {
        self.init(iconImage: iconImage, titleText: titleText, descriptionText: descriptionText, behavior: behavior, delegate: nil, components: components)
    }
    
    init(iconImage: UIImage, titleText: String, descriptionText: String, behavior: String?, delegate: ItemCellSourceDelegate?, components: [ComponentItemTableViewCellSource]) {
        self.iconImage = iconImage
        self.titleText = titleText
        self.descriptionText = descriptionText
        self.behavior = behavior
        self.delegate = delegate
        self.components = components
        
        didSelect = { view, indexPath in
            self.delegate?.didSelect(source: self)
        }
    }
    
}
