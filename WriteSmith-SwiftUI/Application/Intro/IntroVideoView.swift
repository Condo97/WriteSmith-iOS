//
//  IntroVideoView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import AVKit
import Foundation
import SwiftUI
import UIKit

struct IntroVideoView<Content: View>: View {
    
    @State var avPlayer: AVPlayer
    @State var videoAspectRatio: CGFloat
    @ViewBuilder var destination: ()->Content
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let blurryOverlayImageName = "Blurry Overlay"
    
    @State var isShowingNext: Bool = false
    
    
    var videoViewRepresentableTopPadding: CGFloat {
        get {
            // Get device width and height, multiply device width by aspect ratio, subtract product from device height to get top padding if positive otherwise zero
            let additionalOffset = UIScreen.screenWidth < 388 ? 50.0 : 0.0
            print(UIScreen.screenWidth)
            let topPadding = UIScreen.screenWidth * (1 / videoAspectRatio) - UIScreen.screenHeight - additionalOffset
            
            if topPadding < 0 {
                return 0
            }
            
            return topPadding
        }
    }
    
    
    var body: some View {
        ZStack {
            // Background Video View
//            BackgroundVideoView(
//                imageName: colorScheme == .light ? lightModeVideoName : darkModeVideoName,
//                imageExtension: colorScheme == .light ? lightModeVideoExtension : darkModeVideoExtension)
            
            ZStack {
                VideoViewRepresentable(player: avPlayer)
//                    .padding(.top, -50)
            }
            .aspectRatio(videoAspectRatio, contentMode: .fill)
            .padding(.top, videoViewRepresentableTopPadding)
            
            
            
            // Button within container with blurry overlay background
            VStack {
                let additionalYOffset = 80.0
                
                ZStack {
                    Image(blurryOverlayImageName)
                        .resizable()
                        .frame(height: 400)
                        .offset(y: 18)
                        .foregroundStyle(Colors.elementBackgroundColor)
                    
                    Button(action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Show next view
                        isShowingNext = true
                    }) {
                        ZStack {
                            Text("Next...")
                                .font(.custom(Constants.FontName.heavy, size: 24.0))
                            
                            HStack {
                                Spacer()
                                Text(Image(systemName: "chevron.right"))
                            }
                        }
                    }
                    .padding()
                    .foregroundStyle(Colors.elementTextColor)
                    .background(Colors.buttonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    .padding()
//                    .padding(.top, blurryOverlayImageYOffset + buttonYOffset)
//                    .padding()
//                    .padding(.top, -48)
                }
                .offset(y: UIScreen.screenHeight / 2 - additionalYOffset)
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingNext, destination: destination)
        .background(Colors.elementBackgroundColor)
    }
    
}

#Preview {
    
    let avPlayer = AVPlayer(url: Bundle.main.url(forResource: "Scan Image Light", withExtension: "m4v")!)
    
    return IntroVideoView(
        avPlayer: avPlayer,
        videoAspectRatio: 1284.0/2778.0,
        destination: {
        
    })
    
}
