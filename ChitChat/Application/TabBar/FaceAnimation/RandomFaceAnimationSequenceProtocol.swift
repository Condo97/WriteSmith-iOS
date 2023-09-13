//
//  RandomFaceAnimationSequenceProtocol.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

protocol RandomFaceAnimationSequenceProtocol {
    var animationSequence: FaceAnimationSequence { get }
}

extension RandomFaceAnimationSequenceProtocol {
    
    func getRandomAnimationSequence(from animationSequence: [FaceAnimationSequence]) -> FaceAnimationSequence {
        animationSequence[Int.random(in: Range(NSRange(location: 0, length: animationSequence.count))!)]
    }
    
}
