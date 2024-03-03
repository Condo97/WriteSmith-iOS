//
//  IntroPresenterView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/1/23.
//

import SwiftUI

struct IntroPresenterView: View {
    
    @Binding var isShowing: Bool
    
    
    var body: some View {
        NavigationStack {
            IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot1)!), destination: {
                IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot2)!), destination: {
                    IntroVideoView(destination: {
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
