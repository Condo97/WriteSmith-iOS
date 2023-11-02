//
//  FinishedWritingFaceAnimation1_1.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct FinishedWritingFaceAnimation1_1: FaceAnimation {
    struct EyesAnimation: MoveAnimation {
        var moveToPosition: CGPoint = CGPoint(x: 0, y: -8)
    }
    
    struct NoseAnimation: MoveAnimation {
        var moveToPosition: CGPoint = CGPoint(x: 0, y: -4)
    }
    
    struct MouthAnimation: MoveAnimation {
        var moveToPosition: CGPoint = CGPoint(x: 0, y: -4)
    }
    
    struct BackgroundAnimation: MoveAnimation {
        var moveToPosition: CGPoint = CGPoint(x: 0, y: -2)
    }
    
    var eyebrowsAnimation: FacialFeatureAnimation?
    var eyebrowsPosition: EyebrowsPositions? = .dismissed
    var eyesAnimation: FacialFeatureAnimation? = EyesAnimation()
    var noseAnimation: FacialFeatureAnimation? = NoseAnimation()
    var mouthAnimation: FacialFeatureAnimation? = MouthAnimation()
    var mouthPosition: MouthPositions? = .smile
    var backgroundAnimation: FacialFeatureAnimation? = BackgroundAnimation()
    
    var duration: CFTimeInterval = 0.4
}
