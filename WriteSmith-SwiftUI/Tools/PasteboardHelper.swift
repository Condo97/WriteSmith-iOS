//
//  PasteboardHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/25/23.
//

import Foundation
import UIKit

class PasteboardHelper: Any {
    
    static func copy(_ text: String) {
        copy(text, showFooterIfNotPremium: false, isPremium: false)
    }
    
    static func copy(_ text: String, showFooterIfNotPremium: Bool, isPremium: Bool) {
        // Copy to Pasteboard with or without footer
        //TODO: - Make the footer text an option in settings instead of disabling it for premium entirely
        var toCopyText = ""
        if !showFooterIfNotPremium {
            if !isPremium, let shareURL = UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredShareURL) {
                toCopyText = "\(text)\n\n\(Constants.copyFooterText)\n\(shareURL)"
            } else {
                toCopyText = "\(text)"
            }
        }
        
        UIPasteboard.general.string = toCopyText
    }
    
}
