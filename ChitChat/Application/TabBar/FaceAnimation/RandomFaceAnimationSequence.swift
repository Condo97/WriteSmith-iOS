//
//  RandomFaceAnimationSequence.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

enum RandomFaceAnimationSequence: RandomFaceAnimationSequenceProtocol {
    
    private var blinkAnimations: [FaceAnimationSequence] {
        [
            BlinkFaceAnimationSequence()
        ]
    }
    private var finishedWritingAnimations: [FaceAnimationSequence] {
        [
            FinishedWritingFaceAnimationSequence1()
        ]
    }
    
    case blink
    case finishedWriting
    
    var animationSequence: FaceAnimationSequence {
        switch(self) {
        case .blink: return getRandomAnimationSequence(from: blinkAnimations)
        case .finishedWriting: return getRandomAnimationSequence(from: finishedWritingAnimations)
        }
    }
    
}
