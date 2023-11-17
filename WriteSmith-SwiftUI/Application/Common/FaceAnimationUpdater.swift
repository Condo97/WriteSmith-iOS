//
//  FaceAnimationUpdater.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/12/23.
//

import Foundation
import SwiftUI

class FaceAnimationUpdater: ObservableObject {
    
    // TODO: Pretty sure the View should be getting this ViewModel somehow, not this way where this updates the view using its instance, right?
    
    @Published var faceAnimationViewRepresentable: FaceAnimationViewRepresentable?
    
    init(faceAnimationViewRepresentable: FaceAnimationViewRepresentable? = nil) {
        self.faceAnimationViewRepresentable = faceAnimationViewRepresentable
    }
    
    
    func setFaceIdleAnimationToSmile() {
        faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.smile)
    }
    
    func setFaceIdleAnimationToThinking() {
        faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.thinking)
    }
    
    func setFaceIdleAnimationToWriting() {
        faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.writing)
    }
    
}
