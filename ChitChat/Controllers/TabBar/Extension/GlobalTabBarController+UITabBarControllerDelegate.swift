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
                let activityVC = UIActivityViewController(activityItems: [UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) ?? ""], applicationActivities: [])
                
                present(activityVC, animated: true)
            }
            
            return false
        }
        
        return true
    }
    
}
