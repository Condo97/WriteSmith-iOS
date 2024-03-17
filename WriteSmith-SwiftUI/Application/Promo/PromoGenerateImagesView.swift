//
//  PromoGenerateImagesView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/13/24.
//

import Foundation
import SwiftUI

struct PromoGenerateImagesView: View {
    
    @Binding var isShowing: Bool
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var productUpdater: ProductUpdater
    
    private let promoImageLightName = "Generate Images Promo Scroller Light"
    private let promoImageDarkName = "Generate Images Promo Scroller Dark"
    private let blurryOverlayImageName = Constants.ImageName.blurryOverlay
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isShowingUltraView = false
    
    @State private var isAnimatingScroll = false
    
    @State private var promoScrollerYOffset: CGFloat = 0.0
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
                Text("✨ NEW ✨")
                    .font(.custom(Constants.FontName.body, size: 54.0))
                    .padding(.bottom, -8)
                
                Text("Generate images with DALL-E 3")
                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                
                RoundedRectangle(cornerRadius: 14.0)
                    .fill(Colors.text)
                    .opacity(0.4)
                    .frame(height: 0.5)
                    .padding(.top, 8)
                
                ScrollView {
                    Image(uiImage: UIImage(named: colorScheme == .dark ? promoImageDarkName : promoImageLightName)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .offset(y: promoScrollerYOffset)
                    
                    if colorScheme == .dark {
                        Color.black
                            .opacity(0.2)
                    }
                }
                .frame(maxWidth: 380.0)
                .aspectRatio(1.15, contentMode: .fit)
                .scrollIndicators(.never)
                .scrollDisabled(true)
                .overlay(
                    Image(blurryOverlayImageName)
                        .foregroundStyle(Colors.background)
                        .offset(y: 200.0)
                        .allowsHitTesting(false)
                )
//                .padding(.bottom, 12)
                
                Button(action: {
                    playScrollAnimation()
                }) {
                    Text("\(Image(systemName: "arrow.uturn.backward")) Replay")
                        .font(.custom(Constants.FontName.heavyOblique, size: 17.0))
                }
                .foregroundStyle(Colors.elementBackgroundColor)
                .padding(.top, -28)
                .padding(.bottom, 4)
                .opacity(isAnimatingScroll ? 0.0 : 0.8)
                
                Text("Simply ask in chat to generate an image, and watch it **magically** appear.")
                    .font(.custom(Constants.FontName.bodyOblique, size: 16.0))
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing, .bottom])
//                    .padding([.leading, .trailing])
                
//                Text("Upgrade for 99¢ & Unlock...")
//                    .font(.custom(Constants.FontName.bodyOblique, size: 20.0))
                
                
                HStack {
                    let buttonHeight = 40.0
                    
                    Button(action: {
                        isShowing = false
                    }) {
                        Text(Image(systemName: "xmark"))
                            .font(.custom(Constants.FontName.body, size: 24.0))
                    }
                    .frame(width: buttonHeight, height: buttonHeight)
                    .foregroundStyle(Colors.elementBackgroundColor)
                    .padding(12)
                    .background(Colors.elementTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    
                    Button(action: {
                        isShowingUltraView = true
                    }) {
                        ZStack {
                            VStack(spacing: -2.0) {
                                Text("Upgrade Now for 99¢")
                                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                
                                Text("(unlocks image generation)")
                                    .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                            }
                            .padding(.leading, 8)
                            .padding(.trailing, 16)
                            
                            
                            HStack {
                                Spacer()
                                
                                Text(Image(systemName: "chevron.right"))
                                    .font(.custom(Constants.FontName.body, size: 20.0))
                            }
                        }
                    }
                    .frame(height: buttonHeight)
                    .foregroundStyle(Colors.elementTextColor)
                    .padding(12)
                    .background(Colors.elementBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    
                }
            }
        }
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isShowing = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Colors.text)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 24.0))
        .padding()
        .ultraViewPopover(isPresented: $isShowingUltraView)
        .onAppear {
            playScrollAnimation()
        }
        .onReceive(premiumUpdater.$isPremium, perform: { newIsPremium in
            if newIsPremium {
                isShowing = false
            }
        })
    }
    
    func playScrollAnimation() {
        // Ensure not animating scroll, otherwise return
        guard !isAnimatingScroll else {
            return
        }
        
        // Set isAnimatingScroll to true
        isAnimatingScroll = true
        
        // Set initial promoScrollerYOffset
        withAnimation {
            promoScrollerYOffset = 0.0
        }
        
        let animationDuration = 8.0
        if #available(iOS 17.0, *) {
            withAnimation(.easeOut(duration: animationDuration)) {
                promoScrollerYOffset = -500.0
            } completion: {
                withAnimation {
                    isAnimatingScroll = false
                }
            }
        } else {
            withAnimation(.easeOut(duration: animationDuration)) {
                promoScrollerYOffset = -500.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration, execute: {
                withAnimation {
                    isAnimatingScroll = false
                }
            })
        }
    }
    
}


#Preview {
    
    ZStack {
        
    }
    .fullScreenCover(isPresented: .constant(true)) {
        PromoGenerateImagesView(
            isShowing: .constant(true)
        )
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
    }
    
}
