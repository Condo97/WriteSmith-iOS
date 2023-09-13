//
//  DeselectedFaceAnimationSequence1.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/12/23.
//

import FaceAnimation
import Foundation

struct DeselectedFaceAnimationSequence1: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        NeutralCenterFaceAnimation(),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0),
        WaitFaceAnimation(duration: 1.0)
    ]
    
}
