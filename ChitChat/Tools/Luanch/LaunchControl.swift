//
//  LaunchControl.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/12/23.
//

import Foundation

class LaunchControl {
    
    private static let animationTimeInterval = 0.4
    
    private static let launchScreen: UIViewController = {
        RegistryHelper.instantiateInitialViewControllerFromStoryboard(storyboardName: Registry.LaunchScreen.launchScreenStoryboardName)!
    }()
    
    static func present(in view: UIView, animated: Bool) {
        view.addSubview(launchScreen.view)
    }
    
    static func dismiss(animated: Bool) {
        UIView.animate(withDuration: animated ? animationTimeInterval : 0.0) {
            launchScreen.view.removeFromSuperview()
        }
    }
    
}
