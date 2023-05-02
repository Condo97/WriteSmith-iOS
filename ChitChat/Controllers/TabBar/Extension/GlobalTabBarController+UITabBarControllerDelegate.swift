//
//  GlobalTabBarControllerDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import Foundation

extension GlobalTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // If the favorites button is selected, show ultra screen or share depending on tier... Favorites is not even implemented by the way, it's just there as a placeholder for now
        if viewController.isKind(of: FavoritesViewController.self) {
            // If not premium, take to premium purchase, if premium, share
            // TODO: - Make the "premium" or "share" button favorites, and make it show but say they need to subscribe if not subscriped to premium
            if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                //TODO: This sorta thing is repeated a lot
                
                UltraViewControllerPresenter.presentOnTop(animated: true)
            } else {
                // Show share app popup
                ShareViewHelper.shareApp(viewController: self)
            }
            
            return false
        }
        
        // If the Write button is selected again and top view in the navigation controller is conversation view, then transition to the most recent conversation and return false so the tabBar doesn't push
        if let vcAsNavController = viewController as? UINavigationController {
            if let topVC = vcAsNavController.topViewController {
                if let conversationVC = topVC as? ConversationViewController {
                    conversationVC.pushWith(conversation: ConversationResumingManager.conversation ?? ConversationCDHelper.appendConversation()!, animated: true)
                    
                    return false
                }
            }
        }
        
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Do haptic
        HapticHelper.doLightHaptic()
    }
    
}
