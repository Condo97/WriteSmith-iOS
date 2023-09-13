//
//  BottomTabBarViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/21/23.
//

import UIKit
import FaceAnimation

class GlobalTabBarController: UITabBarController {
    
    let exploreTabIndex = 0
    let writeTabIndex = 1
    let essayTabIndex = 2
    
    lazy var firstViewController = writeTabIndex
    
    var faceAnimationController: GlobalTabBarFaceController?
    
    var fromStart = false
    
    private var faceAnimationView: FaceAnimationView?
    private var faceAnimationViewBackgroundImageView: UIImageView?
    private var faceAnimationViewBackgroundRingImageView: UIImageView?
    private var faceContainerView: UIView?
    
    lazy var createTab: UINavigationController = UINavigationController(rootViewController: ExplorePresentationSpecification().viewController)
    //        lazy var essayTab: UINavigationController = UINavigationController(rootViewController: EssayViewController())
    lazy var writeTab: UINavigationController = {
        let conversationViewController = ConversationViewController()
        conversationViewController.shouldShowUltra = true
        conversationViewController.pushToConversation = true
        
        return UINavigationController(rootViewController: conversationViewController)
    }()
    lazy var essaysTab: UINavigationController = UINavigationController(rootViewController: EssayViewController())
    //    lazy var favoritesTab: FavoritesViewController = FavoritesViewController()
    
    var observerID: Int?
    
    override func loadView() {
        super.loadView()
        
        /* Set viewControllers to tabs */
        viewControllers = [
            createTab,
            writeTab,
            essaysTab
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
        
        // Setup and set createTab tabBarItem
        let createTabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: Constants.ImageName.BottomBarImages.createBottomButton)!
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(Colors.elementTextColor),
            selectedImage: UIImage(named: Constants.ImageName.BottomBarImages.createBottomButtonSelected)!
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(Colors.elementTextColor)
        )
        
        createTab.tabBarItem = createTabBarItem
        
        // Setup and set writeTab tabBaritem
        let writeTabBarItem = UITabBarItem(
            title: nil,
            image: nil,
            selectedImage: nil
//            image: UIImage.fromStacked(
//                topImage: UIImage(named: Constants.ImageName.BottomBarImages.chatBottomButtonTopNotSelected)!
//                    .withRenderingMode(.alwaysTemplate)
//                    .withTintColor(Colors.elementTextColor),
//                bottomImage: UIImage(named: Constants.ImageName.BottomBarImages.chatBottomButtonBottom)!
//                    .withRenderingMode(.alwaysTemplate)
//                    .withTintColor(Colors.bottomBarBackgroundColor)
//            ),
//            selectedImage: UIImage.fromStacked(
//                topImage: UIImage(named: Constants.ImageName.BottomBarImages.chatBottomButtonTopSelected)!
//                    .withRenderingMode(.alwaysTemplate)
//                    .withTintColor(Colors.bottomBarBackgroundColor),
//                bottomImage: UIImage(named: Constants.ImageName.BottomBarImages.chatBottomButtonBottom)!
//                    .withRenderingMode(.alwaysTemplate)
//                    .withTintColor(Colors.elementTextColor)
//            )
        )
        
        writeTab.tabBarItem = writeTabBarItem
        
        // Create and set faceContainerView, faceAnimationView, faceAnimationViewBackgroundImage, and faceAnimationViewBackgroundRingImage, and add to respective subviews
        let faceContainerViewWidth: CGFloat = 90.0
        let faceContainerViewHeight: CGFloat = 90.0
        let faceContainerTopPadding: CGFloat = 4
        let faceContainerViewFrame: CGRect = CGRect(x: (tabBar.frame.size.width - faceContainerViewWidth) / 2, y: 0 - tabBar.frame.size.height / 2 + faceContainerTopPadding, width: faceContainerViewWidth, height: faceContainerViewHeight)
        let faceViewInset: CGFloat = 12.0
//        let faceViewFrame: CGRect = CGRect(x: (tabBar.frame.size.width - faceViewWidth) / 2, y: 0 - faceViewHeight * 3 / 8, width: faceViewWidth, height: faceViewHeight)
        let faceViewFrame: CGRect = CGRect(x: faceViewInset / 2, y: faceViewInset / 2, width: faceContainerViewWidth - faceViewInset, height: faceContainerViewHeight - faceViewInset)
        
        faceContainerView = UIView()
        faceContainerView!.frame = faceContainerViewFrame
        faceContainerView!.isUserInteractionEnabled = false
        
        faceAnimationView = FaceAnimationView(frame: faceViewFrame, faceImageName: Constants.ImageName.faceImageName, startAnimation: CenterSmileFaceAnimation(duration: 0.0))
        
        let faceAnimationViewBackgroundImage = UIImage(named: Constants.ImageName.faceTabBarBackgroundImageName)
        faceAnimationViewBackgroundImageView = UIImageView(image: faceAnimationViewBackgroundImage)
        faceAnimationViewBackgroundImageView!.frame = faceContainerView!.bounds
        
        let faceAnimationViewBackgroundRingImage = UIImage(named: Constants.ImageName.faceTabBarBackgroundRingImageName)
        faceAnimationViewBackgroundRingImageView = UIImageView(image: faceAnimationViewBackgroundRingImage)
        faceAnimationViewBackgroundRingImageView!.frame = faceAnimationViewBackgroundImageView!.frame
        
        faceContainerView!.addSubview(faceAnimationViewBackgroundImageView!)
        faceContainerView!.addSubview(faceAnimationViewBackgroundRingImageView!)
        faceContainerView!.addSubview(faceAnimationView!)
        tabBar.addSubview(faceContainerView!)
        faceAnimationController = GlobalTabBarFaceController(faceAnimationView: faceAnimationView!)
        faceAnimationController?.setIdleAnimations(RandomFaceIdleAnimationSequence.smile)
        
        // Setup and set essaysTab tabBarItem
        let essaysTabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: Constants.ImageName.BottomBarImages.essayBottomButtonNotSelected),
            selectedImage: UIImage(named: Constants.ImageName.BottomBarImages.essayBottomButtonSelected)
        )
        
        essaysTab.tabBarItem = essaysTabBarItem
        
        // Get selected if the writeTabIndex is selected
        let selected = selectedIndex == writeTabIndex
        
        // Configure write button
        setWriteButtonAppearance(selected: selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Set tabBar height and y origin
        tabBar.frame.size.height = 180
        tabBar.frame.origin.y = view.frame.height - 180
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Set write button appearance depending on if writeTabIndex is selected
        let selected = selectedIndex == writeTabIndex
        setWriteButtonAppearance(selected: selected)
        
//        // Switch write tab bar item from dark to light and so
//        let writeTabBarItem = UITabBarItem(
//            title: nil,
//            image: UIImage.fromStacked(
//                topImage: UIImage(named: Constants.ImageName.BottomBarImages.chatBottomButtonTopNotSelected)!.withRenderingMode(.alwaysTemplate)
//                    .withTintColor(Colors.elementTextColor),
//                bottomImage: UIImage(named: Constants.ImageName.BottomBarImages.chatBottomButtonBottom)!
//                    .withRenderingMode(.alwaysTemplate)
//                    .withTintColor(Colors.bottomBarBackgroundColor)
//            ),
//            selectedImage: UIImage.fromStacked(
//                topImage: UIImage(named: Constants.ImageName.BottomBarImages.chatBottomButtonTopSelected)!
//                    .withRenderingMode(.alwaysTemplate)
//                    .withTintColor(Colors.bottomBarBackgroundColor),
//                bottomImage: UIImage(named: Constants.ImageName.BottomBarImages.chatBottomButtonBottom)!
//                    .withRenderingMode(.alwaysTemplate)
//                    .withTintColor(Colors.elementTextColor)
//            )
//        )
//
//        writeTab.tabBarItem = writeTabBarItem
    }
    
//    func updateFavoritesTabBarItem() {
//        let isPremium = PremiumHelper.get()
//        let favoritesTabBarItem = UITabBarItem(
//            title: nil,
//            image: UIImage(named: (isPremium ? Constants.ImageName.BottomBarImages.shareBottomButtonNotSelected : Constants.ImageName.BottomBarImages.premiumBottomButtonNotSelected)),
//            selectedImage: nil
//        )
//
//        essaysTab.tabBarItem = favoritesTabBarItem
//    }
    
    func setWriteButtonAppearance(selected: Bool) {
        faceAnimationViewBackgroundImageView!.tintColor = selected ? Colors.elementTextColor : Colors.elementBackgroundColor
        
        faceAnimationViewBackgroundRingImageView!.tintColor = Colors.elementTextColor
        faceAnimationViewBackgroundRingImageView!.alpha = selected ? 0.0 : 1.0
        
        faceAnimationView!.tintColor = selected ? Colors.elementBackgroundColor : Colors.elementTextColor
        faceAnimationView?.setNeedsLayout()
        faceAnimationView?.layoutIfNeeded()
        faceAnimationView?.setNeedsDisplay()
//        faceAnimationView?.setNeedsLayout()
//        faceAnimationView?.layoutIfNeeded()
//        faceAnimationView?.setNeedsDisplay()
    }
    
}

