//
//  ExploreGeneratedViewController+CreationExploreTableViewCellDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/25/23.
//

import Foundation

extension ExploreGeneratedViewController: CreationExploreTableViewCellDelegate {
    
    func copyButtonPressed(_ sender: Any, overlayButton: RoundedButton?, text: String) {
        // Ensure there is text to copy otherwise return
        guard text.count != 0 else {
            return
        }
        
        PasteboardHelper.copy(text, showFooter: !PremiumHelper.get())
        
        // Animate "Copy" to "Copied" and back if sender is UIButton
        if overlayButton != nil {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.05, animations: {
                    overlayButton!.alpha = 1.0
                }, completion: { boolean in
                    UIView.animate(withDuration: 0.2, delay: 1.4, animations: {
                        overlayButton!.alpha = 0.0
                    })
                })
            }
        }
    }
    
    func shareButtonPressed(_ sender: Any, text: String) {
        // Ensure there is text to copy otherwise return
        guard text.count != 0 else {
            return
        }
        
        ShareViewHelper.share(text, viewController: self)
    }
    
    func upgradeButtonPressed(_ sender: Any) {
        UltraViewControllerPresenter.presentOnTop(animated: true)
    }
    
}
