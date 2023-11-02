//
//  NeutralCenterFaceAnimation.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/12/23.
//

import FaceAnimation
import Foundation

struct NeutralCenterFaceAnimation: FullFaceMoveAnimation {
    
    var moveToPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    var eyebrowsPosition: EyebrowsPositions? = .dismissed
    var mouthPosition: MouthPositions? = .neutral
    
    var duration: CFTimeInterval = 0.4
    
}

