//
//  BottomTabBarViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/21/23.
//

import UIKit

class GlobalTabBarController: UITabBarController {
    
    let firstViewController = 1
    
    var fromStart = false
    
    lazy var essayTab: UINavigationController = UINavigationController(rootViewController: ExplorePresentationSpecification().viewController)
//        lazy var essayTab: UINavigationController = UINavigationController(rootViewController: EssayViewController())
    lazy var writeTab: UINavigationController = {
        let conversationViewController = ConversationViewController()
        conversationViewController.shouldShowUltra = false
        conversationViewController.pushToConversation = true
        
        return UINavigationController(rootViewController: conversationViewController)
    }()
    lazy var favoritesTab: FavoritesViewController = FavoritesViewController()
    
    var observerID: Int?
    
    override func loadView() {
        super.loadView()
        
        /* Set viewControllers to tabs */
        viewControllers = [
            essayTab,
            writeTab,
            favoritesTab
        ]
        
        // Set selected index to firstViewController
        selectedIndex = firstViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        // Add self as observer for PremiumStructureUpdaterDelegate in PremiumStructureUpdaterObserverInstance
        observerID = PremiumUpdater.sharedBroadcaster.addObserver(self)//UpdaterBroadcaster.addObserver(self)
        
        // Set up the tab bar colors https://stackoverflow.com/questions/71758640/how-do-i-set-unselected-tab-bar-item-color-using-swift-in-xcode-with-an-ios-15
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.backgroundColor = Colors.bottomBarBackgroundColor
        appearance.stackedLayoutAppearance.normal.iconColor = Colors.elementTextColor
        appearance.stackedLayoutAppearance.selected.iconColor = Colors.elementTextColor

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        /* Setup tab bar items */
        
        let essayTabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: Constants.ImageName.essayBottomButtonNotSelected),
            selectedImage: UIImage(named: Constants.ImageName.essayBottomButtonSelected)
        )
        
        essayTab.tabBarItem = essayTabBarItem
        
        let writeTabBarItem = UITabBarItem(
            title: nil,
            image: UIImage.fromStacked(
                topImage: UIImage(named: Constants.ImageName.chatBottomButtonTopNotSelected)!.withRenderingMode(.alwaysTemplate)
                    .withTintColor(Colors.elementTextColor),
                bottomImage: UIImage(named: Constants.ImageName.chatBottomButtonBottom)!
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(Colors.bottomBarBackgroundColor)
            ),
            selectedImage: UIImage.fromStacked(
                topImage: UIImage(named: Constants.ImageName.chatBottomButtonTopSelected)!
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(Colors.bottomBarBackgroundColor),
                bottomImage: UIImage(named: Constants.ImageName.chatBottomButtonBottom)!
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(Colors.elementTextColor)
            )
        )
        
        writeTab.tabBarItem = writeTabBarItem
        
        // In a method so that it can be updated with the premium structure updater
        updateFavoritesTabBarItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tabBar.frame.size.height = 180
        tabBar.frame.origin.y = view.frame.height - 180
    }
    
    func updateFavoritesTabBarItem() {
        let isPremium = PremiumHelper.get()
        let favoritesTabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: (isPremium ? Constants.ImageName.shareBottomButtonNotSelected : Constants.ImageName.premiumBottomButtonNotSelected)),
            selectedImage: nil
        )
        
        favoritesTab.tabBarItem = favoritesTabBarItem
    }
    
}

