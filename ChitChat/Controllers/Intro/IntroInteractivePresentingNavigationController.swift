//
//  IntroInteractiveViewSet.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

class IntroInteractivePresentingNavigationController: StackedPresentingNavigationController {
    
    // Default empty behaviour should dismiss navigation controller
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        onEmpty = { nav in
            let storyboard = UIStoryboard(name: Constants.mainStoryboardName, bundle: nil)
            let ultraPurchaseVC = storyboard.instantiateViewController(withIdentifier: Constants.ultraPurchaseViewStoryboardIdentifier) as! UltraViewController
            ultraPurchaseVC.fromStart = true
            nav.pushViewController(ultraPurchaseVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove navigation bar
        navigationBar.isHidden = true
        
    }
    
}
