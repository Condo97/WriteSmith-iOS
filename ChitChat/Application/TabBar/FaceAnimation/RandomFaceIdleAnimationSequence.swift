//
//  RandomFaceIdleAnimationSequence.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

enum RandomFaceIdleAnimationSequence: RandomFaceAnimationSequenceProtocol {
    
    private var smileIdleAnimations: [FaceAnimationSequence] {
        [
            SmileIdleFaceAnimationSequence1()
        ]
    }
    
    private var thinkingIdleAnimations: [FaceAnimationSequence] {
        [
            ThinkingIdleFaceAnimationSequence1()
        ]
    }
    
    private var writingIdleAnimations: [FaceAnimationSequence] {
        [
            WritingIdleFaceAnimationSequence1()
        ]
    }
    
    case smile
    case thinking
    case writing
    
    var animationSequence: FaceAnimationSequence {
        switch(self) {
        case .smile: return getRandomAnimationSequence(from: smileIdleAnimations)
        case .thinking: return getRandomAnimationSequence(from: thinkingIdleAnimations)
        case .writing: return getRandomAnimationSequence(from: writingIdleAnimations)
        }
    }
    
}
