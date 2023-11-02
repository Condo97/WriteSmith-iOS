//
//  RoundedView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit

class RoundedView: UIView {
    
    @IBInspectable open var borderWidth: CGFloat = UIConstants.borderWidth
    @IBInspectable open var borderColor: UIColor = UIColor(Colors.elementBackgroundColor)
    @IBInspectable open var cornerRadius: CGFloat = UIConstants.cornerRadius
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
    }
}
