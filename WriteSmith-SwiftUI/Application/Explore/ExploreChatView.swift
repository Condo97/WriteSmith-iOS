//
//  ExploreChatView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct ExploreChatView: View {
    
    @ObservedObject var premiumUpdater: PremiumUpdater
    @Binding var chat: ExploreChat
    
    
    @State private var isShowingUltraView: Bool = false
    
    @State private var copyButtonCopyState: CopyStates = .copy
    
    private enum CopyStates: String {
        case copy = "Copy"
        case copied = "Copied"
    }
    
    private let copyButtonAnimationDuration = 1.0
    
    
    var body: some View {
        VStack {
            Text(chat.chat)
                .font(.custom(Constants.FontName.body, size: 17.0))
                .foregroundStyle(Colors.textOnBackgroundColor)
            
            HStack {
                Spacer()
                
                if !premiumUpdater.isPremium {
                    upgradeButton
                }
                
                copyButton
                
                shareButton
            }
        }
        .ultraViewPopover(
            isPresented: $isShowingUltraView,
            premiumUpdater: premiumUpdater)
    }
    
    var upgradeButton: some View {
        KeyboardDismissingButton(action: {
            // Do light haptic
            HapticHelper.doLightHaptic()
            
            // Show ultra view
            isShowingUltraView = true
        }) {
            Text("\(Image(systemName: "sparkles"))")
                .font(.custom(Constants.FontName.medium, size: 17.0))
            +
            Text(" Upgrade")
                .font(.custom(Constants.FontName.black, size: 17.0))
        }
        .foregroundStyle(Colors.buttonBackground)
        .padding(8)
        .background(Colors.elementTextColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .bounceable()
    }
    
    var copyButton: some View {
        KeyboardDismissingButton(action: {
            // Do light haptic
            HapticHelper.doLightHaptic()
            
            // Copy chat
            PasteboardHelper.copy(chat.chat, showFooterIfNotPremium: true, isPremium: premiumUpdater.isPremium)
            
            // Do little "copied" animation for copy button
            withAnimation {
                copyButtonCopyState = .copied
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + copyButtonAnimationDuration, execute: {
                withAnimation {
                    copyButtonCopyState = .copy
                }
            })
            
        }) {
            Text("\(Image(systemName: "doc.on.doc")) \(copyButtonCopyState.rawValue)")
                .font(.custom(Constants.FontName.medium, size: 17.0))
        }
        .foregroundStyle(Colors.buttonBackground)
        .padding(8)
        .background(Colors.elementTextColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .bounceable()
    }
    
    var shareButton: some View {
        ShareLink(item: chat.chat) {
            Text("\(Image(systemName: "square.and.arrow.up")) Share")
                .font(.custom(Constants.FontName.medium, size: 17.0))
        }
        .foregroundStyle(Colors.buttonBackground)
        .padding(8)
        .background(Colors.elementTextColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .onTapGesture {
            // Do light haptic
            HapticHelper.doLightHaptic()
        }
        .bounceable()
    }
    
}

#Preview {
    ExploreChatView(
        premiumUpdater: PremiumUpdater(),
        chat: .constant(ExploreChat(chat: "This is the chat. This is the chat. This is the chat. This is the chat. This is the chat. This is the chat. This is the chat. This is the chat."))
    )
    .background(Colors.background)
}
