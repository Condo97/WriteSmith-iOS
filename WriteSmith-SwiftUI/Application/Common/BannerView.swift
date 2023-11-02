//
//  BannerView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/30/23.
//

import SwiftUI

struct BannerView: View {
    
    @State var bannerID: String
    
    
    @State private var bannerViewRepresentable: GADBannerViewRepresentable?
    @State private var isBannerViewLoaded: Bool = false
    @State private var adSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            bannerViewRepresentable
                .frame(height: isBannerViewLoaded ? adSize.height : 0)
        }
        .onAppear {
            bannerViewRepresentable = GADBannerViewRepresentable(bannerID: bannerID, isLoaded: $isBannerViewLoaded, adSize: $adSize)
        }
        
    }
}

#Preview {
    BannerView(bannerID: Keys.Ads.Banner.debug)
}
