//
//  ChatViewController+UITextView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/19/23.
//

import Foundation

extension ChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // If textView is inputTextView, update the size and call currently writing
        if textView == rootView.inputTextView {
            updateInputTextViewSize(textView: textView)
            rootView.inputTextViewCurrentlyWriting()
        }
    }
    
    func updateInputTextViewSize(textView: UITextView) {
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
        if textView.contentSize.height < 70.0 {
            // It's one line so should not be scrollable
            textView.isScrollEnabled = false
            
            // Align submit button to Center Y
            rootView.submitButtonBottomConstraint.priority = .defaultLow
            rootView.submitButtonCenterYConstraint.priority = UILayoutPriority(1000)
        } else {
            // It's more than one line so should be scrollable
            textView.isScrollEnabled = true
            
            // Align submit button to bottom
            rootView.submitButtonBottomConstraint.priority = UILayoutPriority(1000)
            rootView.submitButtonCenterYConstraint.priority = .defaultLow
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            dismissKeyboard()
            return false
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // If textView is inputTextView, then call started writing
        if textView == rootView.inputTextView {
            rootView.inputTextViewStartWriting()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // If textView is inputTextView, then call fiished writing
        if textView == rootView.inputTextView {
            rootView.inputTextViewFinishedWriting()
        }
    }
}
