//
//  IntroPresenterView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/1/23.
//

import AVKit
import SwiftUI

struct IntroPresenterView: View {
    
    @Binding var isShowing: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let lightModeGenerateImageVideoName = "Image Generation Demo Light"
    private let lightModeGenerateImageVideoExtension = "mp4"
    private let darkModeGenerateImageVideoName = "Image Generation Demo Dark"
    private let darkModeGenerateImageVideoExtension = "mp4"
    
    private let lightModeScanImageVideoName = "Scan Image Light"
    private let lightModeScanImageVideoExtension = "m4v"
    private let darkModeScanImageVideoName = "Scan Image Dark"
    private let darkModeScanImageVideoExtension = "m4v"
    
    private let videoAspectRatio = 1284.0/2778.0
    
    
    var body: some View {
        let generateImageAVPlayer = AVPlayer(url: Bundle.main.url(
            forResource: colorScheme == .light ? lightModeGenerateImageVideoName : darkModeGenerateImageVideoName,
            withExtension: colorScheme == .light ? lightModeGenerateImageVideoExtension : darkModeGenerateImageVideoExtension)!)
        let scanImageAVPlayer = AVPlayer(url: Bundle.main.url(
            forResource: colorScheme == .light ? lightModeScanImageVideoName : darkModeScanImageVideoName,
            withExtension: colorScheme == .light ? lightModeScanImageVideoExtension : darkModeScanImageVideoExtension)!)
        
//        NavigationStack {
//            IntroVideoView(
//                avPlayer: generateImageAVPlayer,
//                videoAspectRatio: videoAspectRatio,
//                destination: {
//                    IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot2)!), destination: {
//                        IntroVideoView(
//                            avPlayer: scanImageAVPlayer,
//                            videoAspectRatio: videoAspectRatio,
//                            destination: {
//                                UltraView(isShowing: $isShowing)
//                                    .toolbar(.hidden, for: .navigationBar)
//                                    .onAppear {
//                                        IntroManager.isIntroComplete = true
//                                    }
//                            })
//                    })
//                })
//        }
        
        NavigationStack {
            IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot1)!), destination: {
                IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot2)!), destination: {
                    IntroVideoView(
                        avPlayer: generateImageAVPlayer,
                        videoAspectRatio: videoAspectRatio,
                        destination: {
                            IntroVideoView(
                                avPlayer: scanImageAVPlayer,
                                videoAspectRatio: videoAspectRatio,
                                destination: {
                                UltraView(isShowing: $isShowing)
                                    .toolbar(.hidden, for: .navigationBar)
                                    .onAppear {
                                        IntroManager.isIntroComplete = true
                                    }
                            })
                        })
                })
            })
        }
    }
    
}

#Preview {
    IntroPresenterView(isShowing: .constant(true))
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
}
