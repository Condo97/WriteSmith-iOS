//
//  IntroViewController+IntroViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/21/23.
//

import Foundation

extension IntroViewController: IntroViewDelegate {
    
    func nextButtonPressed() {
        stackedPresentingNavigationControllerDelegate?.pushToNext()
    }
    
}
