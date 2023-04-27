//
//  TextViewComponentItemExploreTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/23/23.
//

import Foundation
import UIKit

class TextViewComponentItemExploreTableViewCellSource: NSObject, ComponentItemTableViewCellSource {
    
    // Constants
    private let inputPlaceholder: String = "Tap to start typing..."
    
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
        let textView = PlaceholderTextView()
        textView.font = UIFont(name: Constants.primaryFontName, size: 15.0)
        return textView
    }()
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
        self.init(headerText: headerText, promptPrefix: promptPrefix, required: false)
    }
    
    convenience init(headerText: String, promptPrefix: String, required: Bool) {
        self.init(headerText: headerText, promptPrefix: promptPrefix, detailTitle: nil, detailText: nil, required: required)
    }
    
    init(headerText: String, promptPrefix: String, detailTitle: String?, detailText: String?, required: Bool) {
        self.headerText = headerText
        self.promptPrefix = promptPrefix
        self.detailTitle = detailTitle
        self.detailText = detailText
        self.required = required
        
        doneToolbarController = DoneToolbarController()
        
        super.init()
        
        // Set doneToolbarController and textField delegate after super.init() call
        doneToolbarController.delegate = self
        if let textView = view as? PlaceholderTextView {
            textView.inputPlaceholder = inputPlaceholder
            textView.inputAccessoryView = doneToolbarController.toolbar
            textView.delegate = self
        }
    }
    
}

extension TextViewComponentItemExploreTableViewCellSource: DoneToolbarControllerDelegate {
    
    func doneToolbarButtonPressed(_ sender: Any) {
        // Call finished editing on editing delegate
        editingDelegate?.finishedEditing(source: self)
        
        // End editing on view to dismiss keyboard
        view.endEditing(true)
    }
    
}

extension TextViewComponentItemExploreTableViewCellSource: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Clear the input placeholder text
        if let placeholderTextView = textView as? PlaceholderTextView {
            placeholderTextView.inputTextViewSetToBlank()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Set placeholderTextView if text is blank
        if let placeholderTextView = textView as? PlaceholderTextView {
            if placeholderTextView.text == "" {
                placeholderTextView.inputTextViewSetToPlaceholder()
            }
        }
    }
    
}
