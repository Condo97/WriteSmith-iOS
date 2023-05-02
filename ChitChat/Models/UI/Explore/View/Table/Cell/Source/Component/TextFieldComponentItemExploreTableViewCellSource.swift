//
//  TextFieldComponentItemExploreTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/23/23.
//

import Foundation
import UIKit

class TextFieldComponentItemExploreTableViewCellSource: NSObject,  ComponentItemTableViewCellSource {
    
    // Constants
    private let inputPlaceholder = "Tap to start typing..."
    
    private let PLACEHOLDER_TEXT_ALPHA: CGFloat = 0.4
    
    // Initialization variables
    private let doneToolbarController: DoneToolbarController
    
    var headerText: String
    var promptPrefix: String
    
    var detailTitle: String?
    var detailText: String?
    
    var required: Bool
    
    var editingDelegate: ComponentItemTableViewCellSourceEditingDelegate?
    
    // View and accessor to value of it
    var view: UIView = {
        let textField = UITextField()
        textField.font = UIFont(name: Constants.primaryFontName, size: 15.0)
        textField.backgroundColor = .clear
        textField.textColor = Colors.aiChatTextColor
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
        self.init(headerText: headerText, promptPrefix: promptPrefix, required: false)
    }
    
    convenience init(headerText: String, promptPrefix: String, required: Bool) {
        self.init(headerText: headerText, promptPrefix: promptPrefix, detailTitle: nil, detailText: nil, required: required)
    }
    
    convenience init(headerText: String, promptPrefix: String, detailTitle: String?, detailText: String?) {
        self.init(headerText: headerText, promptPrefix: promptPrefix, detailTitle: detailTitle, detailText: detailText, required: false)
    }
    
    init(headerText: String, promptPrefix: String, detailTitle: String?, detailText: String?, required: Bool) {
        self.headerText = headerText
        self.promptPrefix = promptPrefix
        self.detailTitle = detailTitle
        self.required = required
        
        doneToolbarController = DoneToolbarController()
        
        super.init()
        
        // Set doneToolbarController and textField delegate after super.init() call
        doneToolbarController.delegate = self
        if let textField = view as? UITextField {
            textField.attributedPlaceholder = NSAttributedString(string: inputPlaceholder, attributes: [.foregroundColor: Colors.aiChatTextColor.withAlphaComponent(PLACEHOLDER_TEXT_ALPHA)])
            textField.inputAccessoryView = doneToolbarController.toolbar
            textField.delegate = self
        }
    }
    
}

extension TextFieldComponentItemExploreTableViewCellSource: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // End editing on textField and return false
        textField.endEditing(true)
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Call finished editing on editing delegate
        editingDelegate?.finishedEditing(source: self)
    }
    
}

extension TextFieldComponentItemExploreTableViewCellSource: DoneToolbarControllerDelegate {
    
    func doneToolbarButtonPressed(_ sender: Any) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // End editing on view to dismiss keyboard
        view.endEditing(true)
    }
    
}
