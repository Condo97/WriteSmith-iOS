//
//  TextViewComponentItemExploreTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/23/23.
//

import Foundation

class TextViewComponentItemExploreTableViewCellSource: ComponentItemTableViewCellSource {
    
    // Initialization variables
    var headerText: String
    var promptPrefix: String
    
    var detailTitle: String?
    var detailText: String?
    
    // View and accessor to value of it
    var view: UIView = UITextView()
    var viewHeight: CGFloat = 140
    
    var value: String? {
        get {
            if let textView = view as? UITextView {
                return textView.text
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
