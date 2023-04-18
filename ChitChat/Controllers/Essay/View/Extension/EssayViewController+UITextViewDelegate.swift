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
        if textView == (rootView.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            updateInputTextViewSize(textView: textView)
            
            // If there is text in the textView enable submitButton, otherwise disableSubmitButton
            let entryCell = rootView.tableView.cellForRow(at: IndexPath(row: 0, section: entrySection)) as! EssayEntryTableViewCell
            if textView.text.count != 0 {
                entryCell.submitButton.isEnabled = true
            } else {
                entryCell.submitButton.isEnabled = false
            }
            
            return
        }
    }
    
    func updateInputTextViewSize(textView: UITextView) {
        if textView == (rootView.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            DispatchQueue.main.async {
                let size = CGSize(width: textView.frame.size.width, height: .infinity)
                let estimatedSize = textView.sizeThatFits(size)
                
                textView.constraints.forEach{ (constraint) in
                    if constraint.firstAttribute == .height {
                        self.rootView.tableView.beginUpdates()
                        constraint.constant = estimatedSize.height
                        self.rootView.tableView.endUpdates()
                    }
                }
            }
            
            guard textView.contentSize.height < 70.0 else { textView.isScrollEnabled = true; return }
            
            textView.isScrollEnabled = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == (rootView.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            if text == "\n" {
                view.endEditing(true)
                return false
            }
            
            return true
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == (rootView.tableView.cellForRow(at: IndexPath(row: 0, section: entrySection)) as! EssayEntryTableViewCell).textView {
            setPlaceholderTextViewToBlank(textView: textView)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == ((rootView.tableView.cellForRow(at: IndexPath(row: 0, section: entrySection))) as! EssayEntryTableViewCell).textView {
            setBlankTextViewToPlaceholder(textView: textView)
        }
    }
}
