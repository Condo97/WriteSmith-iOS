//
//  HalfRoundedView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/22/23.
//

import Foundation

class HalfRoundedView: UIView {
    
    @IBInspectable open var roundTop: Bool = true
    @IBInspectable open var borderWidth: CGFloat = Constants.borderWidth
    @IBInspectable open var borderColor: UIColor = Colors.accentColor
    @IBInspectable open var cornerRadius: CGFloat = Constants.cornerRadius
    
    override func draw(_ rect: CGRect) {
        let path: UIBezierPath
        
        if roundTop {
            path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else {
            path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        }
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
        
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
    }
}
