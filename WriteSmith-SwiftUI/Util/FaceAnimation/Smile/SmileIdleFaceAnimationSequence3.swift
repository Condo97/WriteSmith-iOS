//
//  SmileIdleFaceAnimationSequence3.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/4/24.
//

import FaceAnimation
import Foundation

struct SmileIdleFaceAnimationSequence3: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        SmileCenterFaceAnimation(duration: 0.4),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        SmileLookRightFaceAnimation(),
        WaitFaceAnimation(duration: 0.6),
        SmileLookLeftCurveFaceAnimation(),
        WaitFaceAnimation(duration: 0.6),
        SmileCenterFaceAnimation(duration: 0.6),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0)
    ]
    
}
