//
//  BackgroundVideoView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import _AVKit_SwiftUI
import AVFoundation
import Foundation
import SwiftUI

struct BackgroundVideoView: View {
    
    @State var imageName: String
    @State var imageExtension: String
    
    
    var body: some View {
        let avPlayer = AVPlayer(url: Bundle.main.url(forResource: imageName, withExtension: imageExtension)!)
        
        ZStack {
            VideoViewRepresentable(player: avPlayer)
//                .ignoresSafeArea()
        }
    }
    
}

#Preview {
    
    BackgroundVideoView(
        imageName: "Scan Image Light",
        imageExtension: "m4v")
    
}
