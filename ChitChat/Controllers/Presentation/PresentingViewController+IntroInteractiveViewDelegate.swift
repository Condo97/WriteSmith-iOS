//
//  IntroInteractiveViewController+IntroInteractiveViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/27/23.
//

import Foundation

extension StackedViewController: IntroInteractiveViewDelegate {
    
    func nextButtonPressed() {
        stackedPresentingNavigationControllerDelegate?.pushToNext()
    }
    
}
