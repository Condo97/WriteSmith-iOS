//
//  UltraViewPresenter.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/13/23.
//

import Foundation

class UltraViewControllerPresenter: Any {
    
    static func presentOnTop(animated: Bool) {
        present(animated: animated, in: UIApplication.shared.topmostViewController())
    }
    
    private static func present(animated: Bool, in viewController: UIViewController?) {
        let uvc = UltraViewController()
        uvc.modalPresentationStyle = .overFullScreen
        viewController?.present(uvc, animated: true)
    }
    
}
