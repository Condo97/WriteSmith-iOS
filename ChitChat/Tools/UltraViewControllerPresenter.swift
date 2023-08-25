//
//  UltraViewPresenter.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/13/23.
//

import Foundation

class UltraViewControllerPresenter: Any {
    
    static func presentOnTop(animated: Bool) {
        presentOnTop(animated: animated, shouldRestoreFromSettings: false)
    }
    
    static func presentOnTop(animated: Bool, shouldRestoreFromSettings: Bool) {
        present(animated: animated, in: UIApplication.shared.topmostViewController(), shouldRestoreFromSettings: shouldRestoreFromSettings)
    }
    
    private static func present(animated: Bool, in viewController: UIViewController?, shouldRestoreFromSettings: Bool) {
        let uvc = UltraViewController()
        uvc.modalPresentationStyle = .overFullScreen
        uvc.shouldRestoreFromSettings = shouldRestoreFromSettings
        viewController?.present(uvc, animated: true)
    }
    
}
