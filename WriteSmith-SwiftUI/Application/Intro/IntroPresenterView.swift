//
//  IntroPresenterView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/1/23.
//

import SwiftUI

struct IntroPresenterView: View {
    
    @ObservedObject var premiumUpdater: PremiumUpdater
    @Binding var isShowing: Bool
    
    
    var body: some View {
        NavigationStack {
            IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot1)!), destination: {
                IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot2)!), destination: {
                    UltraView(premiumUpdater: premiumUpdater, isShowing: $isShowing)
                        .toolbar(.hidden, for: .navigationBar)
                        .onAppear {
                            IntroManager.isIntroComplete = true
                        }
                })
            })
        }
    }
    
}

#Preview {
    IntroPresenterView(
        premiumUpdater: PremiumUpdater(),
        isShowing: .constant(true))
}
