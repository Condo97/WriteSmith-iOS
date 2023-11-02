//
//  WritingIdleFaceAnimationSequence1.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/12/23.
//

import FaceAnimation
import Foundation

struct WritingIdleFaceAnimationSequence1: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        WritingLookLeftFaceAnimation(),
        WaitFaceAnimation(duration: 0.2),
        WritingLookRightFaceAnimation(),
        WaitFaceAnimation(duration: 0.2)
    ]
    
}
