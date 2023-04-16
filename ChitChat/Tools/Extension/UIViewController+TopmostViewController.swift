//
//  UIViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/13/23.
//

import Foundation

extension UIViewController {
    
    func topmostViewController() -> UIViewController {
        // If presentedViewController is navigation controller, get the topmostViewController from the visible controller
        if let nav = self as? UINavigationController {
            if let visible = nav.visibleViewController {
                return visible.topmostViewController()
            }
        }
        
        // If presentedViewController is tabBar controller, get the selectedViewController from the visible controller
        if let tab = self as? UITabBarController {
            if let selected = tab.selectedViewController {
                return selected.topmostViewController()
            }
        }
        
        // If the presentedViewController is not nil, return its topmost view controller
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topmostViewController()
        }
        
        // Otherwise, return self as it must be the topmost view controller
        return self
    }
    
}
