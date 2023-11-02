//
//  ThinkingLookLeftFaceAnimation.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/11/23.
//

import FaceAnimation
import Foundation

struct ThinkingLookLeftFaceAnimation: FullFaceMoveAnimation {
    
    var moveToPosition: CGPoint = CGPoint(x: -3, y: 0)
    
    var eyebrowsPosition: EyebrowsPositions? = .lowered
    var mouthPosition: MouthPositions? = .thinking
    
    var duration: CFTimeInterval = 0.4
    
}
