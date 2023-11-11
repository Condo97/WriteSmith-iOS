//
//  EssayPromoRowView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/31/23.
//

import SwiftUI

struct EssayPromoRowView: View {
    
    @Binding var isShowingUltraView: Bool
    
    
    var body: some View {
        VStack(spacing: 16.0) {
            Text("Write Essays, Lyrics, Poems and More!")
                .font(.custom(Constants.FontName.heavy, size: 24.0))
                .multilineTextAlignment(.center)
            
            Text("The easiest way to write or brainstorm essays. Just enter a prompt, and generate an essay with unlimited length.")
                .font(.custom(Constants.FontName.body, size: 14.0))
                .multilineTextAlignment(.center)
            
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("•")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                        +
                        Text(" Easily Write Full-Length")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                        +
                        Text(" Essays")
                            .font(.custom(Constants.FontName.body, size: 14.0))
                    }
                    
                    HStack {
                        Text("•")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                        +
                        Text(" Unlimited")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                        +
                        Text(" Word Count")
                            .font(.custom(Constants.FontName.body, size: 14.0))
                    }
                    
                    HStack {
                        Text("•")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                        +
                        Text(" Tap to Edit")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                        +
                        Text(" and Make it Yours")
                            .font(.custom(Constants.FontName.body, size: 14.0))
                    }
                    
                    HStack {
                        Text("•")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                        +
                        Text(" Concise")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                        +
                        Text("Organization")
                            .font(.custom(Constants.FontName.body, size: 14.0))
                    }
                    
                    HStack {
                        Text("•")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                        +
                        Text(" 1-Tap Share")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                    }
                }
                
                Spacer()
            }
            
            VStack {
                Text("Upgrade to Ultra...")
                    .font(.custom(Constants.FontName.mediumOblique, size: 20.0))
                
                Text("(Free 3-Day Trial!)")
                    .font(.custom(Constants.FontName.mediumOblique, size: 14.0))
            }
            
            KeyboardDismissingButton(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Show Ultra View
                isShowingUltraView = true
            }) {
                ZStack {
                    Text("Get 3 Days Free")
                        .font(.custom(Constants.FontName.medium, size: 20.0))
                    
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.custom(Constants.FontName.medium, size: 20.0))
                    }
                }
                .padding()
                .foregroundStyle(Colors.elementTextColor)
                .background(Colors.buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            }
        }
        .padding()
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding([.leading, .trailing])
    }
    
}

#Preview {
    EssayPromoRowView(isShowingUltraView: .constant(false))
        .background(Colors.background)
}
