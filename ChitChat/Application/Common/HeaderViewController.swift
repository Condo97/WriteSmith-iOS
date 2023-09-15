//
//  HeaderNavigationController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/12/23.
//

import Foundation

class HeaderViewController: UpdatingViewController {
    
    var moreMenuBarItem = UIBarButtonItem()
    var shareMenuBarItem = UIBarButtonItem()
//    var ultraMenuBarItem = UIBarButtonItem()
    var navigationSpacer = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup Navigation Bar Appearance (mmake it solid) */
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.topBarBackgroundColor
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        /* Set tintColor */
        navigationController?.navigationBar.tintColor = Colors.elementTextColor
        
        /* Setup Menu Bar Items */
        moreMenuBarItem = createMoreMenuBarItem()
        shareMenuBarItem = createShareMenuBarItem()
//        ultraMenuBarItem = createUltraMenuBarItem()
        
        /* Setup Navigation Spacer */
        navigationSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigationSpacer.width = 14
        
        /* Setup More Constraints */
        moreMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        moreMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        
        /* Setup Share Constraints */
        shareMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        shareMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        
//        /* Setup Ultra Constraints */
//        ultraMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 48.0).isActive = true
//        ultraMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
//        ultraMenuBarItem.customView?.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 24.0, right: 0)
//        if let ultraView = ultraMenuBarItem.customView as? UltraNavigationItemView {
//            let verticalOffset: CGFloat = 1.0
//
//            ultraView.topSpaceConstraint.constant = -verticalOffset
//            ultraView.bottomSpaceConstraint.constant = -verticalOffset
//        }
//
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 140.0, height: 80.0))
        imageView.contentMode = .scaleAspectFit
        
        /* Setup Logo Image */
        let image = UIImage(named: "logoImage")
        imageView.image = image
        imageView.tintColor = Colors.elementTextColor
        navigationItem.titleView = imageView
        
        setLeftMenuBarItems()
        setRightMenuBarItems()
        
    }
    
    override func updatePremium(isPremium: Bool) {
        super.updatePremium(isPremium: isPremium)
        
        // Do all updates on main queue
        DispatchQueue.main.async {
            self.setRightMenuBarItems()
        }
        
    }
    
//    override func updateGeneratedChatsRemaining(remaining: Int) {
//        super.updateGeneratedChatsRemaining(remaining: remaining)
//
//        // Update remaining bar item on main thread
//        DispatchQueue.main.async {
//            // Check if ultraMenuBarItem is in rightBarButtonItems and if not, setRightMenuBarItems
//            if !self.navigationItem.rightBarButtonItems!.contains(where: { $0 === self.ultraMenuBarItem }) {
//                self.setRightMenuBarItems()
//            }
//
//            // Set remaining text
//            if let ultraView = self.ultraMenuBarItem.customView as? UltraNavigationItemView {
//                ultraView.label.text = "\(remaining < 0 ? 0 : remaining)"
//            }
//        }
//    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Set the ultra sparkle gif if the mode changed from dark to light or so
        // TODO: - This code is repeated
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
//        // TODO: Do this better, it also calls a copy pasted code during setup
//        if let ultraNavigationItemView = ultraMenuBarItem.customView as? UltraNavigationItemView {
//            if userInterfaceStyle == .dark {
//                ultraNavigationItemView.imageView.image = UIImage.gifImageWithName(Constants.ImageName.sparkleDarkGif)
//            } else {
//                ultraNavigationItemView.imageView.image = UIImage.gifImageWithName(Constants.ImageName.sparkleLightGif)
//            }
//        }
    }
    
    @objc func openMenu() {
        
    }
    
    @objc func shareApp() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Show share popup
        ShareViewHelper.shareApp(viewController: self)
    }
    
//    @objc func ultraPressed() {
//        // Bounce ultraBarItemView
//        if let ultraView = ultraMenuBarItem.customView as? UltraNavigationItemView {
//            ultraView.bounce(completion: nil)
//        }
//
//        // Present ultraViewController
//        UltraViewControllerPresenter.presentOnTop(animated: true)
//    }
    
    private func createMoreMenuBarItem() -> UIBarButtonItem {
        /* Setup Menu Menu Bar Item */
        let moreImage = UIImage(systemName: "line.3.horizontal")
        let moreImageButton = UIButton(type: .custom)
        
        moreImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        moreImageButton.setBackgroundImage(moreImage, for: .normal)
        moreImageButton.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        moreImageButton.tintColor = Colors.elementTextColor
        
        return UIBarButtonItem(customView: moreImageButton)
    }
    
    private func createShareMenuBarItem() -> UIBarButtonItem {
        /* Setup Share Menu Bar Item */
        let shareImage = UIImage(named: "shareImage")?.withTintColor(Colors.elementTextColor)
        let shareImageButton = UIButton(type: .custom)
        
        shareImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        shareImageButton.setBackgroundImage(shareImage, for: .normal)
        shareImageButton.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
        shareImageButton.tintColor = Colors.elementTextColor
        
        return UIBarButtonItem(customView: shareImageButton)
    }
    
//    private func createUltraMenuBarItem() -> UIBarButtonItem {
//        /* Setup Pro Menu Bar Item */
//        // Set height and width
//        let HEIGHT: CGFloat = 24.0
//        let WIDTH: CGFloat = HEIGHT * 2
//
//        // Get userInterfaceStyle
//        let userInterfaceStyle = traitCollection.userInterfaceStyle
//
//        // Setup ultra navigation item
//        let ultraNavigationItemView = RegistryHelper.instantiateAsView(nibName: Registry.Common.ultraNavigationItemView, owner: self) as! UltraNavigationItemView
//        ultraNavigationItemView.frame = CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT)
//
//        // Set label text to generated chats remaining
//        let remaining = GeneratedChatsRemainingHelper.get()
//        ultraNavigationItemView.label.text = String(describing: remaining < 0 ? 0 : remaining)
//
//        // Set image to light or dark sprakles depending on userInterfaceStyle
//        if userInterfaceStyle == .dark {
//            ultraNavigationItemView.imageView.image = UIImage.gifImageWithName(Constants.ImageName.sparkleDarkGif)
//        } else {
//            ultraNavigationItemView.imageView.image = UIImage.gifImageWithName(Constants.ImageName.sparkleLightGif)
//        }
//
//        // Ådd gesture recognizer to ultraNavigationItemView and return as bar button item
//        ultraNavigationItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ultraPressed)))
//
//        return UIBarButtonItem(customView: ultraNavigationItemView)
//    }
    
    func setLeftMenuBarItems() {
        /* Put things in left navigationBar. Phew! */
//        navigationItem.leftBarButtonItems = [moreMenuBarItem, shareMenuBarItem, navigationSpacer]
        
    }
    
    func setRightMenuBarItems() {
        /* Put things in right navigationBar */
        var rightBarButtonItems: [UIBarButtonItem] = [shareMenuBarItem]
        
//        // If not premium, show proMenuBarItem
//        if !PremiumHelper.get() {
//            rightBarButtonItems.append(UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: #selector(ultraPressed)))
//            rightBarButtonItems.append(self.ultraMenuBarItem)
//        }
        
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
}
