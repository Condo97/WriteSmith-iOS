//
//  ThinkingIdleFaceAnimationSequence1.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct ThinkingIdleFaceAnimationSequence1: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        ThinkingLookLeftCurveFaceAnimation(),
        WaitFaceAnimation(duration: 1.0),
        ThinkingLookRightCurveFaceAnimation(),
        WaitFaceAnimation(duration: 1.0)
    ]
    
}
