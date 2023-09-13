//
//  ChatViewController+UIGestureRecognizerDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/6/23.
//

import Foundation

extension ChatViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
