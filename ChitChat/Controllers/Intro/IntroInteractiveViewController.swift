//
//  IntroInteractiveViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/27/23.
//

import Foundation

class IntroInteractiveViewController: UIViewController {
    
    var controllerDelegate: IntroInteractiveViewControllerDelegate?
    
    
    func set(controllerDelegate: IntroInteractiveViewControllerDelegate) {
        self.controllerDelegate = controllerDelegate
    }
    
}
