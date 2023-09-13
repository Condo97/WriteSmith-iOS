//
//  SmileCenterFaceAnimation.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct SmileCenterFaceAnimation: FaceAnimation {
    struct ZeroMoveAnimation: MoveAnimation {
        var moveToPosition: CGPoint = CGPoint(x: 0, y: 0)
    }
    
    var eyebrowsAnimation: FacialFeatureAnimation? = ZeroMoveAnimation()
    var eyebrowsPosition: EyebrowsPositions? = .dismissed
    var eyesAnimation: FacialFeatureAnimation? = ZeroMoveAnimation()
    var noseAnimation: FacialFeatureAnimation? = ZeroMoveAnimation()
    var mouthAnimation: FacialFeatureAnimation? = ZeroMoveAnimation()
    var mouthPosition: MouthPositions? = .smile
    var backgroundAnimation: FacialFeatureAnimation? = ZeroMoveAnimation()
    
    var duration: CFTimeInterval
    
    init(duration: CFTimeInterval) {
        self.duration = duration
    }
}
