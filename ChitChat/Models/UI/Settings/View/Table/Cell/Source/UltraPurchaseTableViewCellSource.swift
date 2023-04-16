//
//  SettingsTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit

class UltraPurchaseTableViewCellSource: SelectableTableViewCellSource {
    
    var reuseIdentifier: String = Registry.Settings.View.TableView.Cell.ultraPurchase.reuseID
    
    lazy var giftImage: UIImage = UIImage.gifImageWithName(Constants.Settings.View.Table.Cell.UltraPurchase.giftImageName)!
    
    var titleText: String
    var topLabelText: String
    
    var didSelect: (UITableView, IndexPath)->Void
    
    convenience init(didSelect: @escaping (UITableView, IndexPath)->Void) {
        self.init(
            didSelect: didSelect,
            titleText: Constants.Settings.View.Table.Cell.UltraPurchase.defaultTitleText,
            topLabelText: Constants.Settings.View.Table.Cell.UltraPurchase.defaultTopLabelText
        )
    }
    
    init(didSelect: @escaping (UITableView, IndexPath)->Void, titleText: String, topLabelText: String) {
        self.didSelect = didSelect
        self.titleText = titleText
        self.topLabelText = topLabelText
    }
    
}
