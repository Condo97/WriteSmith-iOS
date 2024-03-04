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
    
    private let lightModeVideoName = "Scan Image Light"
    private let lightModeVideoExtension = "m4v"
    private let darkModeVideoName = "Scan Image Dark"
    private let darkModeVideoExtension = "m4v"
    
    private let videoAspectRatio = 1284.0/2778.0
    
    
    var body: some View {
        let avPlayer = AVPlayer(url: Bundle.main.url(
            forResource: colorScheme == .light ? lightModeVideoName : darkModeVideoName,
            withExtension: colorScheme == .light ? lightModeVideoExtension : darkModeVideoExtension)!)
        
        NavigationStack {
            IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot1)!), destination: {
                IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot2)!), destination: {
                    IntroVideoView(
                        avPlayer: avPlayer,
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
        }
    }
    
}

#Preview {
    IntroPresenterView(isShowing: .constant(true))
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
}
