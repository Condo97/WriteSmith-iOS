//
//  BlinkFaceAnimationSequence.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct BlinkFaceAnimationSequence: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [BlinkFaceAnimation()]
    
}
