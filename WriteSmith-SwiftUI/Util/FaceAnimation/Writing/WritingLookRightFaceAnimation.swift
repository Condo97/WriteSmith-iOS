//
//  WritingLookRightFaceAnimation.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/12/23.
//

import FaceAnimation
import Foundation

struct WritingLookRightFaceAnimation: FullFaceMoveCurveAnimation {
    
    var moveToQuadCurvePoint: CGPoint = CGPoint(x: 2, y: 2)
    var moveToQuadCurveControlPoint: CGPoint = CGPoint(x: 1, y: 2.5)
    
    var eyebrowsPosition: EyebrowsPositions? = .rightRaised
    var mouthPosition: MouthPositions? = .thinking
    
    var duration: CFTimeInterval = 1
    
}
