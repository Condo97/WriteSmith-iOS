//
//  ChatView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit

protocol ChatViewDelegate {
    func submitButtonPressed()
    func promoButtonPressed()
    func cameraButtonPressed()
}

class ChatView: UIView {
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var tableView: ChatTableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var promoView: RoundedView!
    @IBOutlet weak var promoShadowView: ShadowView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var upgradeNowPromoView: RoundedView!
    @IBOutlet weak var upgradeNowPromoShadowView: ShadowView!
    @IBOutlet weak var upgradeNowPromoLabel: UILabel!
    @IBOutlet weak var upgradeNowText: UILabel!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adShadowView: ShadowView!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var gptModelView: GPTModelView!
    
    @IBOutlet weak var inputBackgroundView: RoundedView!
    
    @IBOutlet weak var adViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var promoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomViewBottomAlignmentConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var submitButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButtonCenterYConstraint: NSLayoutConstraint!
    
    let SOFT_DISABLE_OPACITY = 0.4
    
    var delegate: ChatViewDelegate?
    var inputPlaceholder: String?
    
    var isGenerating: Bool = false
    var softDisable: Bool = false {
        didSet {
            if softDisable {
                DispatchQueue.main.async {
                    // Soft disable set, so change button opacity to SOFT_DISABLE_OPACITY
                    self.submitButton.alpha = self.SOFT_DISABLE_OPACITY
                }
            } else {
                DispatchQueue.main.async {
                    self.submitButton.alpha = 1.0
                }
            }
        }
    }
    
    var isBlankWithPlaceholder: Bool {
        inputTextView.text == inputPlaceholder
    }
    
    @IBAction func submitButton(_ sender: Any) {
        delegate?.submitButtonPressed()
    }
    
    @IBAction func promoButton(_ sender: Any) {
        delegate?.promoButtonPressed()
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        delegate?.cameraButtonPressed()
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
    
    func inputTextViewStartWriting() {
        // Set inputTextView to blank
        if inputTextView.text == inputPlaceholder {
            // Do haptic
            HapticHelper.doLightHaptic()
            
            inputTextViewSetToBlank()
        }
    }
    
    func inputTextViewCurrentlyWriting() {
        // If text field is blank or isGenerating is true, set the submit button to disabled
        if inputTextView.text == "" || isGenerating {
            DispatchQueue.main.async {
                self.submitButton.isEnabled = false
            }
        } else {
            DispatchQueue.main.async {
                self.submitButton.isEnabled = true
            }
        }
    }
    
    func inputTextViewFinishedWriting() {
        // Set inputTextView to placeholder
        if inputTextView.text == "" {
            inputTextViewSetToPlaceholder()
        }
    }
    
    func inputTextViewOnSubmit(isPremium: Bool) {
        // Set inputTextView to placeholder
        inputTextViewSetToPlaceholder()
        
        // Set isGenerating to true
        isGenerating = true
        
        // Soft disable or full disable
        if !isPremium {
            softDisable = true
        } else {
            DispatchQueue.main.async {
                self.submitButton.isEnabled = false
                self.cameraButton.isEnabled = false
            }
        }
    }
    
    func inputTextViewOnFinishedGenerating() {
        // Set isGenerating to false
        isGenerating = false
        
        DispatchQueue.main.async {
            // If there is text in inputTextView, reenable submitButton
            if self.inputTextView.text.count > 0 && self.inputTextView.text != self.inputPlaceholder {
                self.submitButton.isEnabled = true
            }
        
            // Set cameraButton to enabled, specifically for the hard disable from premium
            self.cameraButton.isEnabled = true
        }
    }
    
    func inputTextViewOnFinishedTyping() {
        // Set softDisable to disabled, specifically for the soft disable from free
        softDisable = false
        
        DispatchQueue.main.async {
            // If there is no text or text is the inputPlaceholder in inputTextView, disable the submitButton
            if self.inputTextView.text.count == 0 || self.inputTextView.text == self.inputPlaceholder {
                self.submitButton.isEnabled = false
            }
        }
    }
    
    func inputTextViewSetToPlaceholder() {
        DispatchQueue.main.async {
            self.inputTextView.text = self.inputPlaceholder
            self.inputTextView.tintColor = .lightText
        }
    }
    
    func inputTextViewSetToBlank() {
        DispatchQueue.main.async {
            self.inputTextView.text = ""
            self.inputTextView.tintColor = Colors.elementTextColor
        }
    }
    
}
