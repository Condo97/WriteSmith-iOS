//
//  PresentingNavigationController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/12/23.
//

import UIKit

protocol StackedPresentingNavigationControllerDelegate {
    
    func pushToNext()
    
}

class StackedPresentingNavigationController: UINavigationController {
    
    var stackedPresentationSpecification: StackedPresentationSpecification?
    
    var viewControllersToPresent: [StackedViewController]?
    
    var onEmpty: (UINavigationController)->Void? = { nav in
        nav.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let viewControllersToPresent = stackedPresentationSpecification?.stackedViewControllers else  {
            onEmpty(self)
            return
        }
        
        guard viewControllersToPresent.count > 0 else {
            onEmpty(self)
            return
        }
        
        // Set controllerDelegate of each viewController
        viewControllersToPresent.forEach({ viewController in
            viewController.stackedPresentingNavigationControllerDelegate = self
        })
        
        self.viewControllersToPresent = viewControllersToPresent
        
        pushViewController((self.viewControllersToPresent?.removeFirst())!, animated: true)
    }
    
    
}

extension StackedPresentingNavigationController: StackedPresentingNavigationControllerDelegate {
    
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
