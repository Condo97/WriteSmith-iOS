//
//  GradientView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import UIKit

class GradientView: UIView {
    @IBInspectable open var gradientColor: UIColor = Constants.bottomButtonGradient
    @IBInspectable open var reversed: Bool = false

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let gradient = CAGradientLayer()
        
//        gradient.startPoint = CGPoint(x: 0, y: 0.0)
//        gradient.endPoint = CGPoint(x: 0, y: 2.0)
        
        if !reversed {
            gradient.colors = [gradientColor.withAlphaComponent(0.0).cgColor, gradientColor.withAlphaComponent(0.5).cgColor, gradientColor.withAlphaComponent(1.0).cgColor]
            gradient.locations = [NSNumber(value: 0.0),NSNumber(value: 0.5),NSNumber(value: 1.0)]
        } else {
            gradient.colors = [gradientColor.withAlphaComponent(1.0).cgColor, gradientColor.withAlphaComponent(0.5).cgColor, gradientColor.withAlphaComponent(0.0).cgColor]
            gradient.locations = [NSNumber(value: 0.0),NSNumber(value: 0.5),NSNumber(value: 1.0)]
        }
        gradient.frame = self.bounds
//        self.layer.mask = gradient
        
        self.layer.insertSublayer(gradient, at: 0)
        
        
        
    }
}
