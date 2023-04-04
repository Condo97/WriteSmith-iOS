//
//  ChatViewController+MainNavigationViewControllerUpdateDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/2/23.
//

import Foundation

extension ChatViewController: PremiumStructureUpdaterDelegate {
    
    func updatePremium(isPremium: Bool) {
        // Do all updates on main queue
        DispatchQueue.main.async {
            // Set bottom purchase buttons
            self.remainingView.isHidden = isPremium
            self.remainingShadowView.isHidden = isPremium
            self.promoView.isHidden = isPremium
            self.promoShadowView.isHidden = isPremium
            
            // Set promoViewHeightConstraint
            self.promoViewHeightConstraint.constant = isPremium ? 0.0 : self.promoViewHeightConstraintConstant
            
            // Set right nav bar button purchase item
            var rightBarButtonItems: [UIBarButtonItem] = []
            if !isPremium {
                rightBarButtonItems.append(self.proMenuBarItem)
            }
            self.navigationItem.rightBarButtonItems = rightBarButtonItems
            
            // Set adView visibility if premium
            if isPremium {
                self.adView.alpha = 0.0
                self.adViewHeightConstraint.constant = 0.0
                self.adShadowView.isHidden = true
            }
            
            // Update right tabBarItem
            let tabBarRightItemIndex = (self.tabBarController!.tabBar.items!.count) - 1
            self.tabBarController!.tabBar.items![tabBarRightItemIndex].image = UIImage(named: (isPremium ? Constants.shareBottomButtonNotSelectedImageName : Constants.premiumBottomButtonNotSelectedImageName))
        }
    }
    
    func updateRemaining(remaining: Int) {
        // Set instance remaining
        self.remaining = remaining
        
        // Set chatsRemainingText on main queue
        DispatchQueue.main.async {
            self.chatsRemainingText.text = "You have \(remaining < 0 ? 0 : remaining) chat\(remaining == 1 ? "" : "s") remaining today..."
        }
    }
    
    private func updateIfIsPremium() {
        
    }
    
}
