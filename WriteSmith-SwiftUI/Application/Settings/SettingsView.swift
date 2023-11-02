//
//  SettingsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import SwiftUI
import WebKit

struct SettingsView: View {
    
    @ObservedObject var premiumUpdater: PremiumUpdater
    
    
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
                    Button(action: {
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
                
                Section {
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
                    
                    Button(action: {
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
                    
                    Button(action: {
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
                    
                    Button(action: {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
            }
            .toolbarBackground(Colors.topBarBackgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .ultraViewPopover(
                isPresented: $isShowingUltraView,
                restoreOnAppear: $restoreOnUltraViewAppear,
                premiumUpdater: premiumUpdater)
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
    
}

#Preview {
    SettingsView(premiumUpdater: PremiumUpdater())
}
