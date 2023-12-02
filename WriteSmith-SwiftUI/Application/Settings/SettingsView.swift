//
//  SettingsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import SwiftUI
import WebKit

struct SettingsView: View {
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    
    
    @State private var restoreOnUltraViewAppear: Bool = false
    
    @State private var isShowingUltraView: Bool = false
    @State private var isShowingTermsWebView: Bool = false
    @State private var isShowingPrivacyWebView: Bool = false
    
    var body: some View {
        VStack {
            if !premiumUpdater.isPremium {
                BannerView(bannerID: Keys.Ads.Banner.settingsView)
            }
            
            List {
                Section {
                    premiumRow
                } footer: {
                    Text("Unlimited chats, GPT-4 access, and the latest AI features as soon as they are released.")
                        .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
                }
                
                Section {
                    hapticsRow
                } footer: {
                    Text("Feel your chats with satisfying haptics.")
                        .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
                }
                
                Section {
                    shareRow
                    
                    termsRow
                    
                    privacyRow
                    
                    restoreRow
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
            }
            .toolbarBackground(Colors.topBarBackgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .ultraViewPopover(
                isPresented: $isShowingUltraView,
                restoreOnAppear: $restoreOnUltraViewAppear)
            .fullScreenCover(isPresented: $isShowingTermsWebView) {
                NavigationStack {
                    VStack {
                        WebView(url: URL(string: "\(HTTPSConstants.chitChatServerStaticFiles)\(HTTPSConstants.termsAndConditions)")!)
                            .toolbar {
                                CloseToolbarItem(isPresented: $isShowingTermsWebView)
                                
                                LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
                            }
                            .toolbarBackground(Colors.elementBackgroundColor, for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                            .navigationBarTitleDisplayMode(.inline)
                            .background(Colors.background)
                            .ignoresSafeArea()
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingPrivacyWebView) {
                NavigationStack {
                    VStack {
                        WebView(url: URL(string: "\(HTTPSConstants.chitChatServerStaticFiles)\(HTTPSConstants.privacyPolicy)")!)
                            .toolbar {
                                CloseToolbarItem(isPresented: $isShowingPrivacyWebView)
                                
                                LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
                            }
                            .toolbarBackground(Colors.elementBackgroundColor, for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                            .navigationBarTitleDisplayMode(.inline)
                            .background(Colors.background)
                            .ignoresSafeArea()
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Colors.background)
    }
    
    var premiumRow: some View {
        Button(action: {
            // Do light haptic
            HapticHelper.doLightHaptic()
            
            // Show Ultra View
            isShowingUltraView = true
        }) {
            HStack {
                SwiftyGif(name: Constants.ImageName.giftGif)
                    .frame(width: 80.0)
                VStack(alignment: .leading) {
                    Text("Claim Free Trial...")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                        .minimumScaleFactor(0.5)
                    Text("Get Unlimited GPT-4 Chats, Scans, Essay Help + More!")
                        .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                        .opacity(0.6)
                }
                
                Spacer()
                
                Text(Image(systemName: "chevron.right"))
                    .font(.custom(Constants.FontName.body, size: 17.0))
            }
        }
        .foregroundStyle(Colors.text)
        .frame(height: 80.0)
    }
    
    var hapticsRow: some View {
        ZStack {
            var isOn: Binding<Bool> {
                Binding(
                    get: {
                        !HapticHelper.hapticsDisabled
                    },
                    set: { newValue in
                        HapticHelper.hapticsDisabled = !newValue
                    })
            }
            
            Toggle(isOn: isOn, label: {
                Text("Haptics Enabled")
                    .font(.custom(Constants.FontName.body, size: 17.0))
            })
        }
    }
    
    var shareRow: some View {
        ShareLink(item: ShareHelper.appShareURL) {
            HStack {
                Text(Image(systemName: "person.3"))
                    .frame(width: 40.0)
                    .font(.custom(Constants.FontName.body, size: 17.0))
                
                Text("Share App")
                    .font(.custom(Constants.FontName.black, size: 17.0))
                +
                Text(" With Friends")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                
                Spacer()
                
                Text(Image(systemName: "chevron.right"))
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
        }
        .foregroundStyle(Colors.text)
        .onTapGesture {
            // Do light haptic
            HapticHelper.doLightHaptic()
        }
    }
    
    var termsRow: some View {
        Button(action: {
            // Do light haptic
            HapticHelper.doLightHaptic()
            
            // SHow terms web view
            isShowingTermsWebView = true
        }) {
            HStack {
                Text(Image(systemName: "newspaper"))
                    .frame(width: 40.0)
                    .font(.custom(Constants.FontName.body, size: 17.0))
                Text("Terms of Use")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                
                Spacer()
                
                Text(Image(systemName: "chevron.right"))
                    .font(.custom(Constants.FontName.body, size: 12.0))
                
            }
        }
        .foregroundStyle(Colors.text)
    }
    
    var privacyRow: some View {
        Button(action: {
            // Do light haptic
            HapticHelper.doLightHaptic()
            
            // Show privacy web view
            isShowingPrivacyWebView = true
        }) {
            HStack {
                Text(Image(systemName: "paperclip"))
                    .frame(width: 40.0)
                    .font(.custom(Constants.FontName.body, size: 17.0))
                
                Text("Privacy Policy")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                
                Spacer()
                
                Text(Image(systemName: "chevron.right"))
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
        }
        .foregroundStyle(Colors.text)
    }
    
    var restoreRow: some View {
        Button(action: {
            // Do light haptic
            HapticHelper.doLightHaptic()
            
            // Set restoreOnUltraViewAppear and isShowingUltraView to true to show Ultra View and restore when it's presented
            restoreOnUltraViewAppear = true
            isShowingUltraView = true
        }) {
            HStack {
                Text(Image(systemName: "arrow.triangle.2.circlepath"))
                    .frame(width: 40.0)
                    .font(.custom(Constants.FontName.body, size: 17.0))
                
                Text("Restore Purchases")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                
                Spacer()
                
                Text(Image(systemName: "chevron.right"))
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
        }
        .foregroundStyle(Colors.text)
    }
    
}

#Preview {
    SettingsView()
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
}
