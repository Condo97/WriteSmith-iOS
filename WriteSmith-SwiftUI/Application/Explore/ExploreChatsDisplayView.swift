//
//  ExploreChatsDisplayView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct ExploreChatsDisplayView: View {
    
    @Binding var chats: [ExploreChat]
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    @EnvironmentObject var remainingUpdater: RemainingUpdater
    
    
    var body: some View {
        VStack {
            if !premiumUpdater.isPremium {
                BannerView(bannerID: Keys.Ads.Banner.exploreChatView)
            }
            
            Spacer(minLength: 20.0)
            
            List($chats) { chat in
                ExploreChatView(chat: chat)
                .listRowBackground(Colors.background)
            }
            .buttonStyle(.plain)
            .listStyle(.plain)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
            
            if !premiumUpdater.isPremium {
                UltraToolbarItem()
            }
        }
        .background(Colors.background)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Colors.elementBackgroundColor, for: .navigationBar)
    }
    
}

#Preview {
    NavigationStack {
        ExploreChatsDisplayView(
            chats: .constant([
                ExploreChat(chat: "Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one!")
            ])
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Colors.elementBackgroundColor, for: .navigationBar)
    }
    .environmentObject(RemainingUpdater())
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
}
