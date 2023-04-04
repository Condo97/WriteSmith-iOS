//
//  EssayViewController+UITextFieldDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

extension EssayViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // Is it the input text field?
        if textView == (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            updateInputTextViewSize(textView: textView)
            updateTextViewSubmitButtonEnabled(textView: textView)
            
            return
        }
    }
    
    func updateInputTextViewSize(textView: UITextView) {
        if textView == (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            let size = CGSize(width: textView.frame.size.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            
            textView.constraints.forEach{ (constraint) in
                if constraint.firstAttribute == .height {
                    self.tableView.beginUpdates()
                    constraint.constant = estimatedSize.height
                    self.tableView.endUpdates()
                }
            }
            
            guard textView.contentSize.height < 70.0 else { textView.isScrollEnabled = true; return }
            
            textView.isScrollEnabled = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            if text == "\n" {
                view.endEditing(true)
                return false
            }
            
            return true
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            if textView.textColor == .lightText {
                textView.text = ""
                textView.textColor = Colors.userChatTextColor
            }
            
            return
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            if textView.text == "" {
                textView.text = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? inputPlaceholder : freeInputPlaceholder
                textView.textColor = .lightText
            }
            
            return
        }
    }
}
