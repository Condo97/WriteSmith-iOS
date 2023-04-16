//
//  DotsAnimation.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/26/23.
//

import Foundation

class DotsView: UIView {
    
    var dots: [DotView] = []
    
    override func draw(_ rect: CGRect) {
        dots.forEach({ dot in
            addSubview(dot)
        })
    }
    
    func resize(at index: Int, by multiplier: CGFloat) {
        self.dots[index].transform = CGAffineTransform(scaleX: multiplier, y: multiplier) // TODO: This or traditional scaling?
    }
    
}
