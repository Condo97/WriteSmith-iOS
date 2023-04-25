//
//  PasteboardHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/25/23.
//

import Foundation

class PasteboardHelper: Any {
    
    static func copy(_ text: String, showFooter: Bool) {
        // Copy to Pasteboard with or without footer
        //TODO: - Make the footer text an option in settings instead of disabling it for premium entirely
        var toCopyText = ""
        if !showFooter {
            if let shareURL = UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) {
                toCopyText = "\(text)\n\n\(Constants.copyFooterText)\n\(shareURL)"
            } else {
                toCopyText = "\(text)\n\n\(Constants.copyFooterText)"
            }
        }
        
        UIPasteboard.general.string = toCopyText
    }
    
}
