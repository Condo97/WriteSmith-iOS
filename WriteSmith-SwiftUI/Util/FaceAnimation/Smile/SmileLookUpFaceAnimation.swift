//
//  SmileLookUpFaceAnimation.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/4/24.
//

import FaceAnimation
import Foundation

struct SmileLookUpFaceAnimation: FullFaceMoveAnimation {
    
    var moveToPosition: CGPoint = CGPoint(x: 0, y: -2)
    
    var eyebrowsPosition: EyebrowsPositions? = .dismissed
    var mouthPosition: MouthPositions? = .smile
    
    var duration: CFTimeInterval = 0.8
    
}
