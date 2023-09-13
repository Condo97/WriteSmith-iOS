//
//  SmileIdleFaceAnimationSequence1.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct SmileIdleFaceAnimationSequence1: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        CenterSmileFaceAnimation(duration: 0.4),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        SmileLookLeftFaceAnimation(),
        WaitFaceAnimation(duration: 0.4),
        SmileLookRightCurveFaceAnimation(),
        WaitFaceAnimation(duration: 0.4),
        CenterSmileFaceAnimation(duration: 0.4),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0)
    ]
    
}
