//
//  ChatViewController+ChatViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/12/23.
//

import Foundation

extension ChatViewController: ChatViewDelegate {
    
    func submitButtonPressed() {
        // Get input text
        let inputText = rootView.inputTextView.text!
        
        // Reset inputTextView
        rootView.inputTextView.text = ""
        updateInputTextViewSize(textView: rootView.inputTextView)
        
        generateChat(inputText: inputText)
        
        dismissKeyboard()
        rootView.inputTextViewOnSubmit()
    }
    
    func promoButtonPressed() {
        goToUltraPurchase()
    }
    
    func cameraButtonPressed() {
        dismissKeyboard()
        
        if submitSoftDisable {
            let alert = UIAlertController(title: "3 Days Free", message: "Scan while chats are typing! Try Ultra for 3 days free today.", preferredStyle: .alert)
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
