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
    @IBOutlet weak var remainingView: RoundedView!
    @IBOutlet weak var remainingShadowView: ShadowView!
    @IBOutlet weak var chatsRemainingText: UILabel!
    @IBOutlet weak var upgradeNowText: UILabel!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adShadowView: ShadowView!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var inputBackgroundView: RoundedView!
    
    @IBOutlet weak var adViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var promoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var submitButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButtonCenterYConstraint: NSLayoutConstraint!
    
    var delegate: ChatViewDelegate?
    var inputPlaceholder: String?
    
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
    
    func inputTextFieldStartWriting() {
        if inputTextView.text == inputPlaceholder {
            inputTextFieldSetToBlank()
        }
    }
    
    func inputTextFieldCurrentlyWriting() {
        if inputTextView.text == "" {
            submitButton.isEnabled = false
        } else {
            submitButton.isEnabled = true
        }
    }
    
    func inputTextFieldFinishedWriting() {
        if inputTextView.text == "" {
            inputTextFieldSetToPlaceholder()
        }
    }
    
    func inputTextField() {
        inputTextFieldSetToPlaceholder()
    }
    
    private func inputTextFieldSetToPlaceholder() {
        inputTextView.text = inputPlaceholder
        inputTextView.tintColor = .lightText
    }
    
    private func inputTextFieldSetToBlank() {
        inputTextView.text = ""
        inputTextView.tintColor = Colors.elementTextColor
    }
    
}
