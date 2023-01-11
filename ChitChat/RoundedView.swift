//
//  RoundedView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit

class RoundedView: UIView {
    
    @IBInspectable open var borderWidth: CGFloat = Constants.borderWidth
    @IBInspectable open var borderColor: UIColor = Colors.accentColor
    @IBInspectable open var cornerRadius: CGFloat = Constants.cornerRadius
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
    }
}
