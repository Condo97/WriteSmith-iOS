//
//  ButtonCollectionViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/27/23.
//

import Foundation

//protocol ButtonCollectionViewCellSourceProtocol {
//    func tappedButton(source: CellSource)
//}

class ButtonCollectionViewCellSource: CellSource, SelectableCellSource {
    
    var collectionViewCellReuseIdentifier: String? = Registry.Common.View.Collection.Cell.roundedViewLabelCollectionViewCell.reuseID
    var tableViewCellReuseIdentifier: String?
    
    var didSelect: ((UIView, IndexPath)->Void)?
    var didSelectSource: ((ButtonCollectionViewCellSource, IndexPath)->Void)?
    
    var darkColor: UIColor = Colors.userChatBubbleColor
    var lightColor: UIColor = Colors.userChatTextColor
    
    var buttonTitle: String
    var selected: Bool
    
    var buttonFromCell: UIButton?
     
    
    init(buttonTitle: String, selected: Bool, didSelectSource: ((ButtonCollectionViewCellSource, IndexPath)->Void)?) {
        self.buttonTitle = buttonTitle
        self.selected = selected
        self.didSelectSource = didSelectSource
        
        didSelect = { view, indexPath in
            didSelectSource?(self, indexPath)
        }
    }
    
}
