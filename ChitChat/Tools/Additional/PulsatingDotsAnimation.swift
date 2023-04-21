//
//  DotsAnimation.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/26/23.
//

import Foundation

class PulsatingDotsAnimation: Any {
    
    static let DEFAULT_ANIMATION_FROM_VALUE: CGFloat = 0.0
    static let DEFAULT_ANIMATION_TO_VALUE: CGFloat = 1.0
    static let DEFAULT_ANIMATION_REPEAT_COUNT: Float = 40
    static let DEFAULT_ANIMATION_AUTOREVERSES: Bool = true
    
    static let DEFAULT_DOT_SMALL_SIZE_RATIO = 1.0/4.0
    
    let dotsView: DotsView
    var animators: [PulsatingDotAnimator]
    
    var isAnimating = false
    
    static func createAnimation(frame: CGRect, amount: Int, duration: CGFloat, color: UIColor) -> PulsatingDotsAnimation {
        // Create dotsView
        let dotsView = DotsView(frame: frame)
        
        // Create animators array
        var animators: [PulsatingDotAnimator] = []
        
        // Create amount of DotViews with drawDot
        for i in 0..<amount {
            // Get the shortest edge of rect for dot height and width and placement
            let byWidth = frame.width > frame.height
            let longestEdge = byWidth ? frame.width : frame.height
            
            // Get minX for each dot by multiplying frame.width with i over the amount
                // Both i and amount need to be independently wrapped because otherwise it will do a fraction and then return the floor and then wrap that number otherwise!
            let diameter = longestEdge * 1.0/CGFloat(amount)
            let minTemp = longestEdge * CGFloat(i)/CGFloat(amount)
            let minX = byWidth ? minTemp : frame.minX + (frame.width - diameter)/2
            let minY = byWidth ? frame.minY + (frame.height - diameter)/2 : minTemp
            
            // Create PulsatingDotAnimator
            let animator = PulsatingDotAnimator(
                frame: CGRect(x: minX, y: minY, width: diameter, height: diameter),
                fromValue: DEFAULT_ANIMATION_FROM_VALUE,
                toValue: DEFAULT_ANIMATION_TO_VALUE,
                duration: duration/2.0,
                repeatCount: DEFAULT_ANIMATION_REPEAT_COUNT,
                autoreverses: DEFAULT_ANIMATION_AUTOREVERSES,
                beginTimeOffset: Double(i) * duration/Double(amount),
                animationKeyIndex: i,
                color: color
            )
            
            dotsView.dots.append(animator.dotView)
            animators.append(animator)
        }
        
        // Make all dots small
        for i in 0..<dotsView.dots.count {
            dotsView.resize(at: i, by: DEFAULT_DOT_SMALL_SIZE_RATIO)
        }
        
        return PulsatingDotsAnimation(dotsView: dotsView, animators: animators)
    }
    
    convenience init() {
        self.init(dotsView: DotsView(), animators: [])
    }
    
    init(dotsView: DotsView, animators: [PulsatingDotAnimator]) {
        self.dotsView = dotsView
        self.animators = animators
    }
    
    func start() {
        animators.forEach({ animator in
            animator.start()
        })
    }
    
    func stop() {
        animators.forEach({ animator in
            animator.stop()
        })
    }
    
}
