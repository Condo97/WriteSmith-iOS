//
//  PulsatingDotAnimator.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/26/23.
//

import Foundation

class PulsatingDotAnimator {
    
    let frame: CGRect
    let fromValue: CGFloat
    let toValue: CGFloat
    let duration: CGFloat
    let repeatCount: Float
    let autoreverses: Bool
    let beginTimeOffset: Double
    let animationKeyIndex: Int
    let color: UIColor
    
    let dotView: DotView
    
    var animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
    var isAnimating: Bool = false
    
    init(frame: CGRect, fromValue: CGFloat, toValue: CGFloat, duration: CGFloat, repeatCount: Float, autoreverses: Bool, beginTimeOffset: Double, animationKeyIndex: Int, color: UIColor) {
        self.frame = frame
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.repeatCount = repeatCount
        self.autoreverses = autoreverses
        self.beginTimeOffset = beginTimeOffset
        self.animationKeyIndex = animationKeyIndex
        self.color = color
        
        dotView = DotView(frame: frame)
    }
    
    func start() {
        if !isAnimating {
            animation.fromValue = fromValue
            animation.toValue = toValue
            animation.duration = duration
            animation.repeatCount = repeatCount
            animation.autoreverses = autoreverses
            animation.beginTime = CACurrentMediaTime() + beginTimeOffset
            
            dotView.layer.backgroundColor = color.cgColor
            
            isAnimating = true
        }
        
        dotView.layer.add(animation, forKey: "dotViewAnimation\(animationKeyIndex)")
    }
    
    func stop() {
        dotView.layer.removeAllAnimations()
    }
}
