//
//  ChatViewController+UITextView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/19/23.
//

import Foundation

extension ChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateInputTextViewSize(textView: textView)
        updateTextViewSubmitButtonEnabled(textView: textView)
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
            submitButtonBottomConstraint.priority = .defaultLow
            submitButtonCenterYConstraint.priority = UILayoutPriority(1000)
        } else {
            // It's more than one line so should be scrollable
            textView.isScrollEnabled = true
            
            // Align submit button to bottom
            submitButtonBottomConstraint.priority = UILayoutPriority(1000)
            submitButtonCenterYConstraint.priority = .defaultLow
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            view.endEditing(true)
            return false
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightText {
            textView.text = ""
            textView.textColor = Colors.elementTextColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = inputPlaceholder
            textView.textColor = .lightText
        }
    }
}
