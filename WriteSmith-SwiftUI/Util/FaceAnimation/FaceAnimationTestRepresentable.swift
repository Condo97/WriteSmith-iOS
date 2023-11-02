//
//  FaceAnimationRepresentable.swift
//
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import FaceAnimation
import SwiftUI
import UIKit

public struct FaceAnimationRepresentable: UIViewRepresentable {
    
    public var frame: CGRect
    public var faceImageName: String
    public var color: UIColor
    public var startAnimation: FaceAnimation?
    
    
    private var faceAnimationView: FaceAnimationView
    
    @State private var isRandomBlinkRunning: Bool = false
    
    private let randomBlinkSecondsMin: UInt64 = 4
    private let randomBlinkSecondsMax: UInt64 = 12
    
    public init(frame: CGRect, faceImageName: String, color: UIColor, startAnimation: FaceAnimation? = nil) {
        self.frame = frame
        self.faceImageName = faceImageName
        self.color = color
        self.startAnimation = startAnimation
        
        self.faceAnimationView = FaceAnimationView(
            frame: frame,
            faceImageName: faceImageName,
            startAnimation: startAnimation)
        self.faceAnimationView.tintColor = color
        
        startRandomBlink()
    }
    
    public func makeUIView(context: Context) -> FaceAnimationView {
//        faceAnimationView = FaceAnimationView(
//            frame: frame,
//            faceImageName: faceImageName,
//            startAnimation: startAnimation)
        
//        faceAnimationView!.tintColor = color
        
//        startRandomBlink()
        
        return faceAnimationView
    }
    
    public func updateUIView(_ uiView: FaceAnimationView, context: Context) {
        uiView.frame = frame
        uiView.tintColor = color
        
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
    }
    
    func setIdleAnimations(_ randomFaceAnimationSequence: RandomFaceAnimationSequenceProtocol) {
        faceAnimationView.setIdleAnimations(randomFaceAnimationSequence.animationSequence.animations)
    }
    
    func queue(_ randomFaceAnimationSequence: RandomFaceAnimationSequenceProtocol) {
        faceAnimationView.queue(faceAnimations: randomFaceAnimationSequence.animationSequence.animations)
    }
    
    public func startRandomBlink() {
        // Blink after random seconds, between 4 and 12
        Task {
            // TODO: Is it okay to do a while true here?
            while true {
                await blinkAfterRandomSeconds()
            }
        }
    }
    
    public func blinkAfterRandomSeconds() async {
        do {
            try await Task.sleep(nanoseconds: UInt64.random(in: randomBlinkSecondsMin...randomBlinkSecondsMax) * 1_000_000_000)
        } catch {
            print("Error sleeping Task when blinking after random seconds in GlobalTabBarFaceController... \(error)")
        }
        
        blink()
    }
    
    public func blink() {
        faceAnimationView.async(faceAnimation: BlinkFaceAnimation())
    }
    
    public func setColor(_ color: UIColor) {
        faceAnimationView.tintColor = color
        
        faceAnimationView.setNeedsDisplay()
    }
    
}

#Preview {
    ZStack {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FaceAnimationRepresentable(
                    frame: CGRect(x: 0, y: 0, width: 200, height: 200),
                    faceImageName: "face_background",
                    color: .aiChatBubble,
                    startAnimation: SmileCenterFaceAnimation(duration: 0.0)
                )
                .frame(width: 200, height: 200)
                .background(.green)
                Spacer()
            }
            Spacer()
        }
    }
}

