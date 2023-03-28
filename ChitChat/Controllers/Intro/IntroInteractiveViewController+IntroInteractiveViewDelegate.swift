//
//  IntroInteractiveViewController+IntroInteractiveViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/27/23.
//

import Foundation

extension IntroInteractiveViewController: IntroInteractiveViewDelegate {
    
    func nextButtonPressed() {
        controllerDelegate?.pushToNext()
    }
    
}
