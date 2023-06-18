//
//  ChatViewController+ChatViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/12/23.
//

import Foundation

extension ChatViewController: ChatViewDelegate {
    
    func submitButtonPressed() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Immediately dismiss keyboard
        dismissKeyboard()
        
        // Ensure submitSoftDisable is not pressed, otherwise show upgrade prompt and return
        guard !rootView.softDisable else {
            let alert = UIAlertController(title: "3 Days Free", message: "Send messages faster! Try Ultra for 3 days free today.", preferredStyle: .alert)
            alert.view.tintColor = Colors.alertTintColor
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Try Now", style: .default, handler: { action in
                self.goToUltraPurchase()
            }))
            present(alert, animated: true)
            return
        }
        
        // Get input text
        let inputText = rootView.inputTextView.text!
        
        // Reset inputTextView
        rootView.inputTextView.text = ""
        updateInputTextViewSize(textView: rootView.inputTextView)
        
        generateChat(inputText: inputText)
        
        // Dismiss keyboard and call inputTextViewOnSubmit to handle softDisable or ßubmit and camera disable
        rootView.inputTextViewOnSubmit(isPremium: PremiumHelper.get())
    }
    
    func promoButtonPressed() {
        goToUltraPurchase()
    }
    
    func cameraButtonPressed() {
        // Immediately dismiss keyboard
        dismissKeyboard()
        
        guard !rootView.softDisable else {
            let alert = UIAlertController(title: "3 Days Free", message: "Scan while chats are typing! Try Ultra for 3 days free today.", preferredStyle: .alert)
            alert.view.tintColor = Colors.alertTintColor
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Try Now", style: .default, handler: { action in
                self.goToUltraPurchase()
            }))
            present(alert, animated: true)
            return
        }
        
        goToCameraView()
    }
    
}
