//
//  SmileLookLeftCurveFaceAnimation.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct SmileLookLeftCurveFaceAnimation: FullFaceMoveCurveAnimation {
    
    var moveToQuadCurvePoint: CGPoint = CGPoint(x: -3, y: 0)
    var moveToQuadCurveControlPoint: CGPoint = CGPoint(x: -1.5, y: 2)
    
    var eyebrowsPosition: EyebrowsPositions? = .dismissed
    var mouthPosition: MouthPositions? = .smile
    
    var duration: CFTimeInterval = 0.4
    
}
