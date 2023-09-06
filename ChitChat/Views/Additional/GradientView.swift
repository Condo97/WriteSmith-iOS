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
    
    var gradientLayer: CAGradientLayer?

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let localGradientLayer = CAGradientLayer()
        
        if !reversed {
            localGradientLayer.colors = [gradientColor.withAlphaComponent(0.0).cgColor, gradientColor.withAlphaComponent(0.5).cgColor, gradientColor.withAlphaComponent(1.0).cgColor]
            localGradientLayer.locations = [NSNumber(value: 0.0),NSNumber(value: 0.5),NSNumber(value: 1.0)]
        } else {
            localGradientLayer.colors = [gradientColor.withAlphaComponent(1.0).cgColor, gradientColor.withAlphaComponent(0.5).cgColor, gradientColor.withAlphaComponent(0.0).cgColor]
            localGradientLayer.locations = [NSNumber(value: 0.0),NSNumber(value: 0.5),NSNumber(value: 1.0)]
        }
        localGradientLayer.frame = self.bounds
        
        // Remove old gradient
        gradientLayer?.removeFromSuperlayer()
        
        // Add new gradient layer
        layer.addSublayer(localGradientLayer)
        
        // Set new gradient layer to gradientLayer
        gradientLayer = localGradientLayer
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setNeedsDisplay()
    }
    
}
