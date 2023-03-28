//
//  IntroInteractiveViewSet.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

class IntroInteractiveNavigationController: UINavigationController {
    
    var presentationSpecification: PresentationSpecification?
    
    // Default empty behaviour should dismiss navigation controller
    var onEmpty: (UINavigationController)->Void? = { nav in        
        let storyboard = UIStoryboard(name: Constants.mainStoryboardName, bundle: nil)
        let ultraPurchaseVC = storyboard.instantiateViewController(withIdentifier: Constants.ultraPurchaseViewStoryboardIdentifier) as! UltraPurchaseViewController
        ultraPurchaseVC.fromStart = true
        nav.pushViewController(ultraPurchaseVC, animated: true)
    }
    
    private var viewControllersToPresent: [any LoadableViewController & IntroInteractiveViewController]?
    
    override func viewDidLoad() {
        // Remove navigation bar
        navigationBar.isHidden = true
        
        // TODO: - Should all of this be moved to a separate class which just modifies this one? Probably
        
        // Present first view, once "next" action is received from delegate, present the next one over the first one
        
        // Get the viewControllersToPresent array from specification
        // TODO: - Try to make a linked list queue!
        guard let viewControllersToPresent = presentationSpecification?.introInteractiveViewControllers else  {
            onEmpty(self)
            return
        }
        
        guard viewControllersToPresent.count > 0 else {
            onEmpty(self)
            return
        }
        
        // Set controllerDelegate of each viewController
        viewControllersToPresent.forEach({ viewController in
            viewController.set(controllerDelegate: self)
        })
        
        self.viewControllersToPresent = viewControllersToPresent
        
        pushViewController((self.viewControllersToPresent?.removeFirst())!, animated: true)
    }
    
}

extension IntroInteractiveNavigationController: IntroInteractiveViewControllerDelegate {
    
    func pushToNext() {
        // If for some reason vctp is nil, treat as empty
        guard viewControllersToPresent != nil else {
            onEmpty(self)
            return
        }
        
        // If empty, call onEmpty
        guard viewControllersToPresent!.count > 0 else {
            onEmpty(self)
            return
        }
        
        // If it can, push to the next viewController
        pushViewController(viewControllersToPresent!.removeFirst(), animated: true)
    }
}
