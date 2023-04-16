//
//  UIApplication+TopmostViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/13/23.
//

import Foundation

extension UIApplication {
    
    func topmostViewController() -> UIViewController? {
        // TODO: This is deprecated so fix it
        // Get the topmost view controller from the key window and return
        self.windows.filter{$0.isKeyWindow}.first?.rootViewController?.topmostViewController()
    }
    
}
