//
//  UltraPurchaseViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/13/23.
//

import Foundation
import SafariServices

extension UltraViewController: UltraViewDelegate {
    
    func closeButtonPressed() {
        closeUltraView()
    }
    
    func privacyPolicyButton() {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.privacyPolicy)")!
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    func termsAndConditionsButton() {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.termsAndConditions)")!
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    func restorePurchasesButton() {
        restorePurchases()
    }
    
}
