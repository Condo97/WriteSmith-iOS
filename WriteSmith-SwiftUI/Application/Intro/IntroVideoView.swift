//
//  IntroVideoView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import Foundation
import SwiftUI

struct IntroVideoView<Content: View>: View {
    
    @ViewBuilder var destination: ()->Content
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let lightModeVideoName = "Scan Image Light"
    private let lightModeVideoExtension = "m4v"
    private let darkModeVideoName = "Scan Image Dark"
    private let darkModeVideoExtension = "m4v"
    
    private let blurryOverlayImageName = "Blurry Overlay"
    
    @State var isShowingNext: Bool = false
    
    var body: some View {
        ZStack {
            // Background Video View
            BackgroundVideoView(
                imageName: colorScheme == .light ? lightModeVideoName : darkModeVideoName,
                imageExtension: colorScheme == .light ? lightModeVideoExtension : darkModeVideoExtension)
            
            // Button within container with blurry overlay background
            VStack {
                Spacer()
                
                ZStack {
                    let blurryOverlayImageYOffset = 220.0
                    let buttonYOffset = 150.0
                    
                    Image(blurryOverlayImageName)
                        .offset(y: blurryOverlayImageYOffset)
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
                    .padding(.top, blurryOverlayImageYOffset + buttonYOffset)
                    .padding()
                }
            }
            
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingNext, destination: destination)
    }
    
}

#Preview {
    
    IntroVideoView(
        destination: {
        
    })
    
}
