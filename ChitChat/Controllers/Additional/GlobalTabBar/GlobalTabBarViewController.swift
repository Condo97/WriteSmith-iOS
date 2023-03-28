//
//  BottomTabBarViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/21/23.
//

import UIKit

class GlobalTabBarViewController: UITabBarController {
    
    let firstViewController = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        // Set up the tab bar colors https://stackoverflow.com/questions/71758640/how-do-i-set-unselected-tab-bar-item-color-using-swift-in-xcode-with-an-ios-15
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.backgroundColor = Colors.bottomBarBackgroundColor
        appearance.stackedLayoutAppearance.normal.iconColor = Colors.elementTextColor
        appearance.stackedLayoutAppearance.selected.iconColor = Colors.elementTextColor

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        setupWrite()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedIndex = firstViewController
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tabBar.frame.size.height = 180
        tabBar.frame.origin.y = view.frame.height - 180
    }
    
    func setupWrite() {
        // Center tab bar item should be WriteSmith with a background circle image for the secondary color
        if let tabBarItemCount = tabBar.items?.count {
            let middleTabBarItem = tabBarItemCount / 2 // Swift rounds down
            
            // Setup the selected image, which is topSelectedImage on bottomSelectedImage, with element background color as foreground and element text color as background
            let selectedImage = UIImage.fromStacked(
                topImage: UIImage(named: Constants.chatBottomButtonTopSelectedImageName)!
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(Colors.bottomBarBackgroundColor),
                bottomImage: UIImage(named: Constants.chatBottomButtonBottomImageName)!
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(Colors.elementTextColor)
            )
            
            // Setup the not selected image, which is topNotSelectedImage on bottom selected image, with tint colors reversed
            let notSelectedImage = UIImage.fromStacked(
                topImage: UIImage(named: Constants.chatBottomButtonTopNotSelectedImageName)!.withRenderingMode(.alwaysTemplate)
                    .withTintColor(Colors.elementTextColor),
                bottomImage: UIImage(named: Constants.chatBottomButtonBottomImageName)!
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(Colors.bottomBarBackgroundColor)
            )
            
            tabBar.items![middleTabBarItem].selectedImage = selectedImage
            tabBar.items![middleTabBarItem].image = notSelectedImage
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupWrite()
    }
}

extension GlobalTabBarViewController: UITabBarControllerDelegate {
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
