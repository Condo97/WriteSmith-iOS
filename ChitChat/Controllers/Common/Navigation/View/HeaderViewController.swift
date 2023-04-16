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
        
        /* Setup Menu Menu Bar Item */
        let moreImage = UIImage(systemName: "line.3.horizontal")
        let moreImageButton = UIButton(type: .custom)
        
        moreImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        moreImageButton.setBackgroundImage(moreImage, for: .normal)
        moreImageButton.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        moreImageButton.tintColor = Colors.elementTextColor
        
        moreMenuBarItem = UIBarButtonItem(customView: moreImageButton)
        
        /* Setup Share Menu Bar Item */
        let shareImage = UIImage(named: "shareImage")?.withTintColor(Colors.elementTextColor)
        let shareImageButton = UIButton(type: .custom)
        
        shareImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        shareImageButton.setBackgroundImage(shareImage, for: .normal)
        shareImageButton.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
        shareImageButton.tintColor = Colors.elementTextColor
        
        shareMenuBarItem = UIBarButtonItem(customView: shareImageButton)
        
        /* Setup Pro Menu Bar Item */
        //TODO: - New Pro Image
        let proImage = UIImage.gifImageWithName(Constants.ImageName.giftGif)
        let proImageButton = RoundedButton(type: .custom)
        proImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        proImageButton.tintColor = Colors.elementTextColor
        proImageButton.setImage(proImage, for: .normal)
        proImageButton.addTarget(self, action: #selector(ultraPressed), for: .touchUpInside)
        
        proMenuBarItem = UIBarButtonItem(customView: proImageButton)
        
        /* Setup Navigation Spacer */
        navigationSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigationSpacer.width = 14
        
        /* Setup More */
        moreMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
        moreMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        /* Setup Share */
        shareMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
        shareMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        /* Setup Constraints */
        
        proMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 34).isActive = true
        proMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 140, height: 80))
        imageView.contentMode = .scaleAspectFit
        
        // Setup logoImage
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
    
    @objc func openMenu() {
        navigationController?.pushViewController(SettingsPresentationSpecification().presentableViewController, animated: true)
    }
    
    @objc func shareApp() {
        let activityVC = UIActivityViewController(activityItems: [UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) ?? ""], applicationActivities: [])
        
        present(activityVC, animated: true)
    }
    
    @objc func ultraPressed() {
        UltraViewControllerPresenter.presentOnTop(animated: true)
    }
    
}
