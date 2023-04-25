//
//  Bounceable.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

protocol Bounceable: UIView {
    
    func beginBounce(completion: (()->Void)?)
    func endBounce(completion: (()->Void)?)
    func bounce(completion: (()->Void)?)
    
}

extension Bounceable {
    
    // This is cool! This would not work Bounceable was a class, because it would not allow for multiple inheritance from UIView. However, creating a protocol that extends UIView and providing a default implementation for beginBounce and endBounce, they can be used even if the view inherits from a different UIView!
    
    // Bounce TableView Cell
    func beginBounce(completion: (()->Void)?) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { boolean in
            completion?()
        }
    }
    
    func endBounce(completion: (()->Void)?) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { boolean in
            completion?()
        }
    }
    
    func bounce(completion: (()->Void)?) {
        beginBounce() {
            self.endBounce() {
                completion?()
            }
        }
    }
    
}
