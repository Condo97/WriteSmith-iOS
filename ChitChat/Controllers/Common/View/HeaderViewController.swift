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
    var proMenuBarItem = UIBarButtonItem()
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
        
        /* Setup Menu Menu Bar Item */
        let moreImage = UIImage(systemName: "line.3.horizontal")
        let moreImageButton = UIButton(type: .custom)
        
        moreImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        moreImageButton.setBackgroundImage(moreImage, for: .normal)
        moreImageButton.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        moreImageButton.tintColor = Colors.elementTextColor
        
        moreMenuBarItem = UIBarButtonItem(customView: moreImageButton)
        
        /* Setup Share Menu Bar Item */
        let shareImage = UIImage(named: "shareImage")?.withTintColor(Colors.elementTextColor)
        let shareImageButton = UIButton(type: .custom)
        
        shareImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        shareImageButton.setBackgroundImage(shareImage, for: .normal)
        shareImageButton.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
        shareImageButton.tintColor = Colors.elementTextColor
        
        shareMenuBarItem = UIBarButtonItem(customView: shareImageButton)
        
        /* Setup Pro Menu Bar Item */
        //TODO: - New Pro Image
        let proImage = UIImage.gifImageWithName(Constants.ImageName.giftGif)
        let proImageButton = RoundedButton(type: .custom)
        proImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        proImageButton.tintColor = Colors.elementTextColor
        proImageButton.setBackgroundImage(proImage, for: .normal)
        proImageButton.addTarget(self, action: #selector(ultraPressed), for: .touchUpInside)
        
        proMenuBarItem = UIBarButtonItem(customView: proImageButton)
        
        /* Setup Navigation Spacer */
        navigationSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigationSpacer.width = 14
        
        /* Setup More */
        moreMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        moreMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        
        /* Setup Share */
        shareMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        shareMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        
        /* Setup Constraints */
        
        proMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 34).isActive = true
        proMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
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
    
    @objc func openMenu() {
        
    }
    
    @objc func shareApp() {
        ShareViewHelper.shareApp(viewController: self)
    }
    
    @objc func ultraPressed() {
        UltraViewControllerPresenter.presentOnTop(animated: true)
    }
    
    func setLeftMenuBarItems() {
        /* Put things in left navigationBar. Phew! */
        navigationItem.leftBarButtonItems = [moreMenuBarItem, shareMenuBarItem, navigationSpacer]
        
    }
    
    func setRightMenuBarItems() {
        /* Put things in right navigationBar */
        var rightBarButtonItems: [UIBarButtonItem] = []
        
        // If not premium, show proMenuBarItem
        if !PremiumHelper.get() {
            rightBarButtonItems.append(self.proMenuBarItem)
        }
        
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
}
