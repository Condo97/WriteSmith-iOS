//
//  ShadowView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit

class ShadowView: UIView {
    
    @IBInspectable open var shadowColor: UIColor = Colors.userChatBubbleColor
    @IBInspectable open var shadowRadius: CGFloat = 20.0

    override func draw(_ rect: CGRect) {
        
        let shadow = CALayer()
        shadow.masksToBounds = false
        shadow.shadowColor = shadowColor.cgColor
        shadow.shadowRadius = shadowRadius
        shadow.shadowOpacity = 1.0
        shadow.shadowOffset = .zero
        shadow.shadowPath = UIBezierPath(rect: rect).cgPath
        
        layer.insertSublayer(shadow, at: 0)
        layer.insertSublayer(shadow, at: 1)
    }
}
