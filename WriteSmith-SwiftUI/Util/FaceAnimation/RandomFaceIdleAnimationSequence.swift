//
//  RandomFaceIdleAnimationSequence.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

enum RandomFaceIdleAnimationSequence: RandomFaceAnimationSequenceProtocol {
    
    private var numberOfAnimationsToCombine: Int {
        get {
            5
        }
    }
    
    private var deselectedIdleAnimations: [FaceAnimationSequence] {
        [
            DeselectedFaceAnimationSequence1()
        ]
    }
    
    private var smileIdleAnimations: [FaceAnimationSequence] {
        [
            SmileIdleFaceAnimationSequence1(),
            SmileIdleFaceAnimationSequence2(),
            SmileIdleFaceAnimationSequence3()
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
    
    case deselected
    case smile
    case thinking
    case writing
    
    var animationSequence: FaceAnimationSequence {
        switch(self) {
        case .deselected: return getCombinedRandomAnimationSequence(from: deselectedIdleAnimations, numberOfRandomSequencesToCombine: numberOfAnimationsToCombine)
        case .smile: return getCombinedRandomAnimationSequence(from: smileIdleAnimations, numberOfRandomSequencesToCombine: numberOfAnimationsToCombine)
        case .thinking: return getCombinedRandomAnimationSequence(from: thinkingIdleAnimations, numberOfRandomSequencesToCombine: numberOfAnimationsToCombine)
        case .writing: return getCombinedRandomAnimationSequence(from: writingIdleAnimations, numberOfRandomSequencesToCombine: numberOfAnimationsToCombine)
        }
    }
    
}
