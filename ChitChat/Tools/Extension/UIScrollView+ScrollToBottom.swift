//
//  UIScrollView+ScrollToBottom.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/25/23.
//

import Foundation

extension UIScrollView {
    
    func scrollToBottom(animated: Bool) {
        if !animated {
            doContentOffsetScroll()
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
                self.doContentOffsetScroll()
            })
        }
    }
    
    private func doContentOffsetScroll() {
        contentOffset.y = contentSize.height - frame.size.height
    }
    
}
