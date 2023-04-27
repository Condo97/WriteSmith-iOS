//
//  PlaceholderTextView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/26/23.
//

import Foundation

class PlaceholderTextView: UITextView {
    
    var inputPlaceholder: String?
    
    func inputTextViewSetToPlaceholder() {
        DispatchQueue.main.async {
            self.text = self.inputPlaceholder
            self.textColor = self.textColor?.withAlphaComponent(0.8)
        }
    }
    
    func inputTextViewSetToBlank() {
        DispatchQueue.main.async {
            self.text = ""
            self.textColor = self.textColor?.withAlphaComponent(1.0)
        }
    }
    
}
