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
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Close ultraView
        closeUltraView()
    }
    
    func privacyPolicyButton() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Show privacy policy
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let url = URL(string: "\(HTTPSConstants.chitChatServerStaticFiles)\(HTTPSConstants.privacyPolicy)")!
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    func termsAndConditionsButton() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Show terms and conditions
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let url = URL(string: "\(HTTPSConstants.chitChatServerStaticFiles)\(HTTPSConstants.termsAndConditions)")!
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    func restorePurchasesButton() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Do restore purchases
        restorePurchases()
    }
    
}
