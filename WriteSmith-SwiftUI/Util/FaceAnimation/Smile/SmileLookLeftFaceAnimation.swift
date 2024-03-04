//
//  SmileLookLeftFaceAnimation.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/11/23.
//

import FaceAnimation
import Foundation

struct SmileLookLeftFaceAnimation: FullFaceMoveAnimation {
    
    var moveToPosition: CGPoint = CGPoint(x: -3, y: 0)
    
    var eyebrowsPosition: EyebrowsPositions? = .dismissed
    var mouthPosition: MouthPositions? = .smile
    
    var duration: CFTimeInterval = 0.6
    
}
