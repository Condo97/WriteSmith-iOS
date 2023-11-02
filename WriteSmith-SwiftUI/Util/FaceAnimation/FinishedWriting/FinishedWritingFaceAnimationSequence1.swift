//
//  FinishedWritingFaceAnimationSequence1.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct FinishedWritingFaceAnimationSequence1: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        FinishedWritingFaceAnimation1_1(),
        WaitFaceAnimation(duration: 0.4)
    ]
    
}
