//
//  GPTModelSelectionView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/25/23.
//

import SwiftUI

struct GPTModelSelectionView: View {
    
    @Binding var isShowing: Bool
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    
    
    @State private var alertShowingUpgradeToPremium: Bool = false
    
    @State private var isShowingUltraView: Bool = false
    
    var body: some View {
//        ZStack {
//            MaterialView(.systemMaterialDark)
//                .ignoresSafeArea()
//                .transition(.opacity)
            
//            VStack {
//                Spacer()
                VStack {
                    VStack {
                        Text("Choose Model")
                            .font(.custom(Constants.FontName.black, size: 24.0))
                            .padding(.bottom)
                        
                        HStack(alignment: .top) {
                            Text("GPT-3 Turbo:")
                                .font(.custom(Constants.FontName.blackOblique, size: 14.0))
                            +
                            Text(" The ultimate blend of speed and creativity.")
                                .font(.custom(Constants.FontName.body, size: 14.0))
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        
                        HStack(alignment: .top) {
                            Text("Pro GPT-4:")
                                .font(.custom(Constants.FontName.blackOblique, size: 14.0))
                            +
                            Text(" Upgrade your writing with this game-changing leap forward in AP intelligence. Trained on over 1 trillion parameters, this is by far the smartest AI.")
                                .font(.custom(Constants.FontName.body, size: 14.0))
                        }
                    }
                    .padding()
                    .foregroundStyle(Colors.aiChatTextColor)
                    .background(Colors.aiChatBubbleColor)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    //                .padding(.bottom)
                    
                    VStack {
                        KeyboardDismissingButton(action: {
                            // Do light haptic
                            HapticHelper.doLightHaptic()
                            
                            // Set currentChatModel to gpt3turbo
                            GPTModelHelper.currentChatModel = GPTModels.gpt3turbo
                            
                            // Dismiss
                            withAnimation {
                                isShowing = false
                            }
                        }) {
                            ZStack {
                                HStack {
                                    if GPTModelHelper.currentChatModel == .gpt3turbo {
                                        Text(Image(systemName: "checkmark.circle"))
                                            .font(.custom(Constants.FontName.body, size: 34.0))
                                            .padding(.leading)
                                            .padding(.trailing, -20)
                                    }
                                    
                                    Spacer()
                                    HStack {
                                        Text("Enable")
                                            .font(.custom(Constants.FontName.body, size: 24.0))
                                        +
                                        Text(" GPT-3 Turbo")
                                            .font(.custom(Constants.FontName.black, size: 24.0))
                                    }
                                    .padding()
                                    Spacer()
                                }
                                .foregroundStyle(Colors.buttonBackground)
                            }
                        }
                        .background(
                            ZStack {
                                let cornerRadius = 14.0
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .fill(Colors.elementTextColor)
//                                RoundedRectangle(cornerRadius: cornerRadius)
//                                    .stroke(Colors.elementBackgroundColor, lineWidth: 3.0)
                            }
                        )
                        .padding(.bottom, 4)
                        //                .background(.blue)
                        
                        KeyboardDismissingButton(action: {
                            if premiumUpdater.isPremium {
                                // Do light haptic
                                HapticHelper.doLightHaptic()
                                
                                // Set currentChatModel to gpt4
                                GPTModelHelper.currentChatModel = GPTModels.gpt4
                                
                                // Dismiss
                                withAnimation {
                                    isShowing = false
                                }
                            } else {
                                // Do warning haptic
                                HapticHelper.doWarningHaptic()
                                
                                // Show upgrade to premium alert
                                alertShowingUpgradeToPremium = true
                            }
                        }) {
                            HStack {
                                if GPTModelHelper.currentChatModel == .gpt4 {
                                    Text(Image(systemName: "checkmark.circle"))
                                        .font(.custom(Constants.FontName.body, size: 34.0))
                                        .padding(.leading)
                                        .padding(.trailing, -20)
                                }
                                
                                Spacer()
                                HStack {
                                    Text("Enable")
                                        .font(.custom(Constants.FontName.body, size: 24.0))
                                    +
                                    Text(" Pro GPT-4")
                                        .font(.custom(Constants.FontName.black, size: 24.0))
                                }
                                .padding()
                                Spacer()
                            }
                            .foregroundStyle(Colors.elementTextColor)
                        }
                        .background(
                            ZStack {
                                let cornerRadius = 14.0
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .fill(Colors.buttonBackground)
//                                RoundedRectangle(cornerRadius: cornerRadius)
//                                    .stroke(Colors.elementBackgroundColor, lineWidth: 4.0)
                            }
                        )
                        .padding(.bottom, 4)
                    }
                }
                .padding()
                .background(Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                
                KeyboardDismissingButton(action: {
                    // Do light haptic
                    HapticHelper.doLightHaptic()
                    
                    // Dismiss
                    withAnimation {
                        isShowing = false
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Close")
                            .font(.custom(Constants.FontName.body, size: 24.0))
                        Spacer()
                    }
                }
                .foregroundStyle(Colors.aiChatTextColor)
                .padding()
                .background(Colors.aiChatBubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                .transition(.move(edge: .bottom))
                .alert("Free Trial Unlocked", isPresented: $alertShowingUpgradeToPremium, actions: {
                    Button("Close", role: .cancel, action: {
                        
                    })
                    
                    Button("Try for FREE", role: nil, action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Show Ultra View
                        isShowingUltraView = true
                    })
                }) {
                    Text("Unlock GPT-4 FREE for 3 days. Upgrade your essays and be part of the AI revolution")
                }
                .ultraViewPopover(isPresented: $isShowingUltraView)
            }
//        }
//    }
    
}

#Preview {
    ZStack {
        GPTModelSelectionView(
            isShowing: .constant(true))
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
    }
//    .background(Colors.background)
}
