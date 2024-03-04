//
//  VideoViewRepresentable.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import AVKit
import Foundation
import SwiftUI

struct VideoViewRepresentable : UIViewControllerRepresentable {
    
    var player : AVPlayer
    
    private var controller: AVPlayerViewController
    
    init(player: AVPlayer) {
        self.player = player
        
        self.controller = AVPlayerViewController()
        self.controller.player = player
        self.controller.showsPlaybackControls = false
        
        self.controller.videoGravity = .resizeAspectFill
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        let controller = AVPlayerViewController()
//        controller.player = player
//        controller.showsPlaybackControls = false
        
        player.play()
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//        let controller = AVPlayerViewController()
//        controller.player = player
//        controller.showsPlaybackControls = false
        
        player.play()
        
//        return controller
    }
    
}
