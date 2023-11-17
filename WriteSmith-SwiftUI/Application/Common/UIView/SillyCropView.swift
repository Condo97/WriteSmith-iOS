//
//  SillyCropView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 2/1/23.
//

import UIKit

class SillyCropView: UIView {
    
    let borderWidth = 2.0
    let circleSize = 20
    
    let topView = RoundedView()
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        
        
//        let topLeftPath = UIBezierPath(ovalIn: )
//        let topRightPath = UIBezierPath(ovalIn: CGRect(x: Int(rect.maxX) + circleSize / 2, y: Int(rect.minY) - circleSize / 2, width: circleSize, height: circleSize))
//        let bottomLeftPath = UIBezierPath(ovalIn: CGRect(x: Int(rect.minX) - circleSize / 2, y: Int(rect.maxY) + circleSize / 2, width: circleSize, height: circleSize))
//        let bottomRightPath = UIBezierPath(ovalIn: CGRect(x: Int(rect.maxX) + circleSize / 2, y: Int(rect.maxY) + circleSize / 2, width: circleSize, height: circleSize))
//
//        let topLeftShapeLayer = CAShapeLayer()
//        let topRightShapeLayer = CAShapeLayer()
//        let bottomLeftShapeLayer = CAShapeLayer()
//        let bottomRightShapeLayer = CAShapeLayer()
//
//        topLeftShapeLayer.path = topLeftPath.cgPath
//        topRightShapeLayer.path = topRightPath.cgPath
//        bottomLeftShapeLayer.path = bottomLeftPath.cgPath
//        bottomRightShapeLayer.path = bottomRightPath.cgPath
//
//        topLeftShapeLayer.fillColor = Colors.aiChatTextColor.cgColor
//        topRightShapeLayer.fillColor = Colors.aiChatTextColor.cgColor
//        bottomLeftShapeLayer.fillColor = Colors.aiChatTextColor.cgColor
//        bottomRightShapeLayer.fillColor = Colors.aiChatTextColor.cgColor
//
//        topLeftShapeLayer.lineWidth = 3
//        topRightShapeLayer.lineWidth = 3
//        bottomLeftShapeLayer.lineWidth = 3
//        bottomRightShapeLayer.lineWidth = 3
//
//        topLeftShapeLayer.strokeColor = Colors.aiChatTextColor.cgColor
//        topRightShapeLayer.strokeColor = Colors.aiChatTextColor.cgColor
//        bottomLeftShapeLayer.strokeColor = Colors.aiChatTextColor.cgColor
//        bottomRightShapeLayer.strokeColor = Colors.aiChatTextColor.cgColor
//
//        layer.addSublayer(topLeftShapeLayer)
//        layer.addSublayer(topRightShapeLayer)
//        layer.addSublayer(bottomLeftShapeLayer)
//        layer.addSublayer(bottomRightShapeLayer)
        
        layer.borderWidth = borderWidth
        layer.borderColor = UIColor.darkGray.cgColor
    }
}
