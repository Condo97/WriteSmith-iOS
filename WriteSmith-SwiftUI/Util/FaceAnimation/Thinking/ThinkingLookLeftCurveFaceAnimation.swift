//
//  ThinkingLookLeftCurveFaceAnimation.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct ThinkingLookLeftCurveFaceAnimation: FullFaceMoveCurveAnimation {
    
    var moveToQuadCurvePoint: CGPoint = CGPoint(x: -3, y: 0)
    var moveToQuadCurveControlPoint: CGPoint = CGPoint(x: -1.5, y: 2)
    
    var eyebrowsPosition: EyebrowsPositions? = .lowered
    var mouthPosition: MouthPositions? = .thinking
    
    var duration: CFTimeInterval = 0.4
    
}
