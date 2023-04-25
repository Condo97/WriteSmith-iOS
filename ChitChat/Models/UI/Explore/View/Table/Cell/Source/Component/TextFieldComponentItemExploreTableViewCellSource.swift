//
//  TextFieldComponentItemExploreTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/23/23.
//

import Foundation

class TextFieldComponentItemExploreTableViewCellSource: ComponentItemTableViewCellSource {
    
    // Initialization variables
    var headerText: String
    var promptPrefix: String
    
    var detailTitle: String?
    var detailText: String?
    
    // View and accessor to value of it
    var view: UIView = {
        let textField = UITextField()
        textField.font = UIFont(name: Constants.primaryFontName, size: 14.0)
        return textField
    }()
    var viewHeight: CGFloat = 48
    
    var value: String? {
        get {
            if let textField = view as? UITextField {
                return textField.text
            }
            
            return nil
        }
    }
    
    convenience init(headerText: String, promptPrefix: String) {
        self.init(headerText: headerText, promptPrefix: promptPrefix, detailTitle: nil, detailText: nil)
    }
    
    init(headerText: String, promptPrefix: String, detailTitle: String?, detailText: String?) {
        self.headerText = headerText
        self.promptPrefix = promptPrefix
        self.detailTitle = detailTitle
        self.detailText = detailText
    }
    
}
