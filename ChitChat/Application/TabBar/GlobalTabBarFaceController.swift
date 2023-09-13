//
//  GlobalTabBarFaceController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

class GlobalTabBarFaceController {
    
    private let randomBlinkSecondsMin: UInt64 = 4
    private let randomBlinkSecondsMax: UInt64 = 12
    
    private var faceAnimationView: FaceAnimationView
    
    init(faceAnimationView: FaceAnimationView) {
        self.faceAnimationView = faceAnimationView
        
        startRandomBlink()
    }
    
    func setIdleAnimations(_ randomFaceAnimationSequence: RandomFaceAnimationSequenceProtocol) {
        faceAnimationView.setIdleAnimations(randomFaceAnimationSequence.animationSequence.animations)
    }
    
    func queue(_ randomFaceAnimationSequence: RandomFaceAnimationSequenceProtocol) {
        faceAnimationView.queue(faceAnimations: randomFaceAnimationSequence.animationSequence.animations)
    }
    
    func startRandomBlink() {
        // Blink after random seconds, between 4 and 12
        Task {
            // TODO: Is it okay to do a while true here?
            while true {
                await blinkAfterRandomSeconds()
            }
        }
    }
    
    func blinkAfterRandomSeconds() async {
        do {
            try await Task.sleep(nanoseconds: UInt64.random(in: randomBlinkSecondsMin...randomBlinkSecondsMax) * 1_000_000_000)
        } catch {
            print("Error sleeping Task when blinking after random seconds in GlobalTabBarFaceController... \(error)")
        }
        
        blink()
    }
    
    func blink() {
        faceAnimationView.async(faceAnimation: BlinkFaceAnimation())
    }
    
}
