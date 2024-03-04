//
//  PromoSendImagesView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/16/23.
//

import SwiftUI

struct PromoSendImagesView: View {
    
    @Binding var isShowing: Bool
    var pressedScan: ()->Void
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var productUpdater: ProductUpdater
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isShowingUltraView = false
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
                Text("✨ NEW ✨")
                    .font(.custom(Constants.FontName.body, size: 54.0))
                    .padding(.bottom, -8)
                
                Text("Send images to GPT-4")
                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                
                RoundedRectangle(cornerRadius: 14.0)
                    .fill(Colors.text)
                    .opacity(0.4)
                    .frame(width: 280.0, height: 0.5)
                    .padding([.top, .bottom], 8)
            
                Text("GPT now understands **images**, just like a human.")
                    .font(.custom(Constants.FontName.bodyOblique, size: 16.0))
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing])
                
                ZStack {
                    Image(uiImage: UIImage(named: "Animal Cell Scan Wider")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    if colorScheme == .dark {
                        Color.black
                            .opacity(0.2)
                    }
                }
                .frame(maxHeight: 280.0)
                .padding(.bottom, -12)
                
                Text("Upgrade for FREE & Unlock...")
                    .font(.custom(Constants.FontName.bodyOblique, size: 20.0))
                
                Text("(or, just scan image as text \(Image(systemName: "text.viewfinder")))")
                    .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
                    .padding(.bottom)
                
                
                HStack {
                    let buttonHeight = 40.0
                    
                    Button(action: {
                        pressedScan()
                    }) {
                        Text(Image(systemName: "text.viewfinder"))
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
                                Text("Upgrade + FREE Trial")
                                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                
                                Text("(unlocks image messaging)")
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
        .onReceive(premiumUpdater.$isPremium, perform: { newIsPremium in
            if newIsPremium {
                isShowing = false
            }
        })
    }
    
}

#Preview {
    ZStack {
        Colors.foreground
        
        PromoSendImagesView(
            isShowing: .constant(true),
            pressedScan: {
                
            })
        .environmentObject(PremiumUpdater())
//            .background(Colors.background)
    }
}
