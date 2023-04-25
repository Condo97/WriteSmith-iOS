//
//  EssayEntryTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/22/23.
//

import UIKit

protocol EntryEssayTableViewCellDelegate: AnyObject {
    func didPressSubmitButton(sender: Any)
}

class EssayEntryTableViewCell: UITableViewCell, LoadableCell {

    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    let inputPlaceholder = "Enter a prompt..."
    let tryInputPlaceholder = "Enter a prompt to try..."
    
    var isGenerating: Bool = false
    
    var delegate: EntryEssayTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func submitButton(_ sender: Any) {
        if delegate != nil {
            delegate.didPressSubmitButton(sender: sender)
        }
    }
    
    func loadWithSource(_ source: CellSource) {
        if let entrySource = source as? EntryEssayTableViewCellSource {
            delegate = entrySource.cellDelegate
            textView.delegate = entrySource.textViewDelegate
            
            textView.text = entrySource.useTryPlaceholderWhenLoaded ? tryInputPlaceholder : inputPlaceholder
            submitButton.isEnabled = false
        }
    }
    
    //MARK: InputTextField Functions
    
    /***
     Using InputTextField Functions
     
     Call inputTextViewStartedWriting on textViewDidBeginEditing
     Call inputTextViewCurrentlyWriting on textViewDidChange
     Call inputTextViewFinishedWriting on textViewDidEndEditing
     Call inputTextViewOnSubmit when user submits button
     Call inputTextViewOnFinishedGenerating when the chat finishes generating
     Call inputTextViewOnFinishedTyping when the chat finishes typing
     
     Check isPremium and softDisable on submit button
        If !isPremium and !softDisable, generate the chat
        If !isPremium and softDisable, show the alert
        if isPremium regardless of softDisable, generate the chat
     */
    
    func textViewStartWriting() {
        // Set inputTextView to blank
        if textView.text == inputPlaceholder || textView.text == tryInputPlaceholder {
            textViewSetToBlank()
        }
    }
    
    func textViewCurrentlyWriting() {
        // If text field is blank or isGenerating is true, set the submit button to disabled
        if textView.text == "" || isGenerating {
            DispatchQueue.main.async {
                self.submitButton.isEnabled = false
            }
        } else {
            DispatchQueue.main.async {
                self.submitButton.isEnabled = true
            }
        }
    }
    
    func textViewFinishedWriting(useTryPlaceholder: Bool) {
        // Set inputTextView to placeholder
        if textView.text == "" {
            textViewSetToPlaceholder(useTryPlaceholder: useTryPlaceholder)
        }
    }
    
    func textViewOnSubmit(useTryPlaceholder: Bool) {
        // Set inputTextView to placeholder
        textViewSetToPlaceholder(useTryPlaceholder: useTryPlaceholder)
        
        // Set isGenerating to true
        isGenerating = true
        
        // Disable submitButton and textView
        DispatchQueue.main.async {
            self.submitButton.isEnabled = false
            
        }
    }
    
    func textViewOnFinishedGenerating() {
        // Set isGenerating to false
        isGenerating = false
        
        DispatchQueue.main.async {
            // If there is text in textView, reenable submitButton and textView
            if self.textView.text.count > 0 && self.textView.text != self.inputPlaceholder && self.textView.text != self.tryInputPlaceholder {
                self.submitButton.isEnabled = true
            }
        }
    }
    
    func textViewSetToPlaceholder(useTryPlaceholder: Bool) {
        DispatchQueue.main.async {
            self.textView.text = useTryPlaceholder ? self.tryInputPlaceholder : self.inputPlaceholder
            self.textView.tintColor = .lightText
        }
    }
    
    func textViewSetToBlank() {
        DispatchQueue.main.async {
            self.textView.text = ""
            self.textView.tintColor = Colors.elementTextColor
        }
    }
    
}
