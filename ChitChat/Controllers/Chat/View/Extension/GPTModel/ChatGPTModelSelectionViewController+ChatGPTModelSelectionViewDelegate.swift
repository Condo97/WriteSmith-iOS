//
//  ChatGPTModelSelectionViewController+ChatGPTModelSelectionViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/10/23.
//

import Foundation

extension ChatGPTModelSelectionViewController: ChatGPTModelSelectionViewDelegate {
    
    func didPressFreeModelButton() {
        delegate?.didSetGPTModel(model: .gpt3turbo)
        
        moveAndDismiss()
    }
    
    func didPressPaidModelButton() {
        // Check for paid status
        if PremiumHelper.get() {
            // If premium, set the GPT model to paid
            delegate?.didSetGPTModel(model: .gpt4)
            
            moveAndDismiss()
        } else {
            // If not premium, show the popup promoting premium and the free trial
            showPremiumPromotionPopup()
        }
    }
    
    @objc func didPressCloseButton() {
        moveAndDismiss()
    }
    
}
