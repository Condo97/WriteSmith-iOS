//
//  PlaceholderTextView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/26/23.
//

import Foundation

class PlaceholderTextView: UITextView {
    
    let DISABLED_ALPHA: CGFloat = 0.4
    let ENABLED_ALPHA: CGFloat = 1.0
    
    var inputPlaceholder: String?
    
    func textIsPlaceholder() -> Bool {
        return text == inputPlaceholder && textColor == textColor?.withAlphaComponent(DISABLED_ALPHA)
    }
    
    func inputTextViewSetToPlaceholder() {
        DispatchQueue.main.async {
            self.text = self.inputPlaceholder
            self.textColor = self.textColor?.withAlphaComponent(self.DISABLED_ALPHA)
        }
    }
    
    func inputTextViewSetToBlank() {
        DispatchQueue.main.async {
            self.text = ""
            self.textColor = self.textColor?.withAlphaComponent(self.ENABLED_ALPHA)
        }
    }
    
}
