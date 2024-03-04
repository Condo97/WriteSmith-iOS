//
//  SmileIdleFaceAnimationSequence2.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/4/24.
//

import FaceAnimation
import Foundation

struct SmileIdleFaceAnimationSequence2: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        SmileCenterFaceAnimation(duration: 0.4),
        WaitFaceAnimation(duration: 1.0),
        SmileLookUpFaceAnimation(),
        WaitFaceAnimation(duration: 0.4),
        SmileCenterFaceAnimation(duration: 0.4),
        WaitFaceAnimation(duration: 3.0)
    ]
    
}
