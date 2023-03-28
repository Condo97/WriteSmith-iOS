//
//  DotView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/26/23.
//

import Foundation

class DotView: UIView {
    
    var animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
    var isAnimating: Bool = false
    
    override func draw(_ rect: CGRect) {
        // Setup corner radius to be a circle or oval
        let shortSide = rect.width > rect.height ? rect.height : rect.width
        
        layer.cornerRadius = shortSide / 2
    }
    
}
