//
//  BottomTabBarViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/21/23.
//

import UIKit

class BottomTabBarViewController: UITabBarController {
    
    let firstViewController = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        // Make the tabBar totally transparent
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = Colors.userChatBubbleColor

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedIndex = firstViewController
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
}

extension BottomTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController.isKind(of: FavoritesNavigationViewController.self) {
            // If not premium, take to premium purchase, if premium, share
            // TODO: - Make the "premium" or "share" button favorites, and make it show but say they need to subscribe if not subscriped to premium
            if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                performSegue(withIdentifier: "toUltraPurchase", sender: nil)
            } else {
                let activityVC = UIActivityViewController(activityItems: [UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) ?? ""], applicationActivities: [])
                
                present(activityVC, animated: true)
            }
            
            return false
        }
        
        return true
    }
}
