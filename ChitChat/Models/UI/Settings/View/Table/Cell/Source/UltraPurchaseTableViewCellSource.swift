//
//  SettingsTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit

class UltraPurchaseTableViewCellSource: SelectableCellSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? = Registry.Settings.View.Table.Cell.ultraPurchase.reuseID
    
    lazy var giftImage: UIImage = UIImage.gifImageWithName(Constants.Settings.View.Table.Cell.UltraPurchase.giftImageName)!
    
    var titleText: String
    var topLabelText: String
    
    var didSelect: ((UIView, IndexPath)->Void)?
    
    convenience init(didSelect: ((UIView, IndexPath)->Void)?) {
        self.init(
            didSelect: didSelect,
            titleText: Constants.Settings.View.Table.Cell.UltraPurchase.defaultTitleText,
            topLabelText: Constants.Settings.View.Table.Cell.UltraPurchase.defaultTopLabelText
        )
    }
    
    init(didSelect: ((UIView, IndexPath)->Void)?, titleText: String, topLabelText: String) {
        self.didSelect = didSelect
        self.titleText = titleText
        self.topLabelText = topLabelText
    }
    
}
