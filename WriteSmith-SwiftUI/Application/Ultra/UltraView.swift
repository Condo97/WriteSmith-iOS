//
//  UltraView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import SwiftUI

struct UltraView: View {
    
    @ObservedObject var premiumUpdater: PremiumUpdater
    @Binding var restoreOnAppear: Bool
    @Binding var isShowing: Bool
    
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @ObservedObject private var ultraViewModel: UltraViewModel
    
    @State private var tappedPeriod: SubscriptionPeriod?
    
    @State private var isCloseButtonEnlarged: Bool = false
    
    @State private var alertShowingErrorRestoringPurchases: Bool = false
    
    @State private var isShowingTermsWebView: Bool = false
    @State private var isShowingPrivacyWebView: Bool = false
    
    private let closeButtonEnlargeDelay = 2.0
    
    init(premiumUpdater: PremiumUpdater, restoreOnAppear: Binding<Bool> = .constant(false), isShowing: Binding<Bool>) {
        self.premiumUpdater = premiumUpdater
        self._restoreOnAppear = restoreOnAppear
        self._isShowing = isShowing
        
        self.ultraViewModel = UltraViewModel(premiumUpdater: premiumUpdater)
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .overlay(alignment: .bottom) {
                    VStack {
                        topImagesAndPromoText
                            .padding(.bottom, 4)
//                            .ignoresSafeArea()
                        
                        featuresList
                            .padding([.leading, .trailing])
                            .padding(.bottom, 8)
                        
                        purchaseButtons
                            .padding([.leading, .trailing])
                            .padding(.bottom, 4)
                        
                        iapRequiredButtons
                            .padding([.leading, .trailing])
                            .padding(.bottom)
                        
                    }
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
            
            ZStack {
                VStack {
                    HStack {
                        closeButton
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
        .background(Colors.foreground)
        .alert("Error restoring purchases...", isPresented: $alertShowingErrorRestoringPurchases, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }) {
            Text("You can try tapping on the subsciption you previously purchased. Apple will prevent a double charge.")
        }
        .onAppear {
            // Start restore logic if restoreOnAppear is true, and set restoreOnAppear to false once started
            if restoreOnAppear {
                restore()
                
                restoreOnAppear = false
            }
            
            // Start close button enlarge timer
            Timer.scheduledTimer(withTimeInterval: closeButtonEnlargeDelay, repeats: false, block: { timer in
                withAnimation {
                    isCloseButtonEnlarged = true
                }
            })
        }
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
    
    var topImagesAndPromoText: some View {
        VStack(spacing: 0.0) {
            Image(colorScheme == .dark ? Constants.ImageName.Ultra.ultraDark : Constants.ImageName.Ultra.ultraLight)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(colorScheme == .dark ? 0.8 : 1.0)
//                .frame(maxWidth: horizontalSizeClass == .regular ? 200.0 : .infinity)
            
            Text("Unlimited Messages, Image Chats & More!")
                .font(.custom(Constants.FontName.bodyOblique, size: 17.0))
                .foregroundStyle(Colors.elementBackgroundColor)
                .padding(.top, -28)
        }
    }
    
    var featuresList: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack(alignment: .top) {
                Text(Image(systemName: "checkmark.square.fill"))
                    .font(.custom(Constants.FontName.body, size: 24.0))
                
                Text(" GPT-4 + Vision")
                    .font(.custom(Constants.FontName.black, size: 24.0))
                +
                Text(" ")
                    .font(.custom(Constants.FontName.body, size: 24.0))
            }
            
            HStack(alignment: .top) {
                Text(Image(systemName: "checkmark.square.fill"))
                    .font(.custom(Constants.FontName.body, size: 24.0))
                
                Text(" Send Images,\n")
                    .font(.custom(Constants.FontName.black, size: 24.0))
                +
                Text(" Cancel Anytime")
                    .font(.custom(Constants.FontName.body, size: 24.0))
            }
            
            HStack(alignment: .top) {
                Text(Image(systemName: "checkmark.square.fill"))
                    .font(.custom(Constants.FontName.body, size: 24.0))
                
                Text(" Enhanced")
                    .font(.custom(Constants.FontName.black, size: 24.0))
                +
                Text(" Memory")
                    .font(.custom(Constants.FontName.body, size: 24.0))
            }
            
            HStack(alignment: .top) {
                Text(Image(systemName: "checkmark.square.fill"))
                    .font(.custom(Constants.FontName.body, size: 24.0))
                
                Text(" Remove")
                    .font(.custom(Constants.FontName.black, size: 24.0))
                +
                Text(" Ads")
                    .font(.custom(Constants.FontName.body, size: 24.0))
            }
        }
        .foregroundStyle(Colors.text)
        .multilineTextAlignment(.leading)
    }
    
    var purchaseButtons: some View {
        VStack(spacing: 8.0) {
            Text("Directly Supports the Developer - Cancel Anytime")
                .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                .padding(.bottom, -6)
                .opacity(0.6)
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Set tapped period to weekly and purchase
                tappedPeriod = .weekly
                
                purchase()
            }) {
                ZStack {
                    HStack {
                        Spacer()
                        VStack {
                            Text("3 Day Tiral - Then 6.95 / week")
                                .font(.custom(Constants.FontName.black, size: 20.0))
                            Text("Start Free Trial & Plan")
                                .font(.custom(Constants.FontName.body, size: 17.0))
                        }
                        Spacer()
                    }
                    
                    if ultraViewModel.isLoading && tappedPeriod == .weekly {
                        HStack {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
            .padding(12)
            .foregroundStyle(.white)
            .tint(.white)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                        .fill(Colors.buttonBackground)
                }
            )
            .opacity(ultraViewModel.isLoading ? 0.4 : 1.0)
            .disabled(ultraViewModel.isLoading)
            .bounceable(disabled: ultraViewModel.isLoading)
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Set tapped period to monthly and purchase
                tappedPeriod = .monthly
                
                purchase()
            }) {
                ZStack {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Monthly - 19.99 / month")
                                .font(.custom(Constants.FontName.body, size: 20.0))
                            Text("That's 30% Off Weekly!")
                                .font(.custom(Constants.FontName.heavy, size: 17.0))
                        }
                        Spacer()
                    }
                    
                    if ultraViewModel.isLoading && tappedPeriod == .monthly {
                        HStack {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
            .padding(12)
            .foregroundStyle(Colors.buttonBackground)
            .tint(Colors.buttonBackground)
            .background(
                ZStack {
                    let cornerRadius = UIConstants.cornerRadius
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(colorScheme == .dark ? Colors.textOnBackgroundColor : Colors.foreground)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Colors.buttonBackground, lineWidth: 2.0)
                }
            )
            .opacity(ultraViewModel.isLoading ? 0.4 : 1.0)
            .disabled(ultraViewModel.isLoading)
            .bounceable(disabled: ultraViewModel.isLoading)
        }
    }
    
    var iapRequiredButtons: some View {
        HStack {
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Show privacy web view
                isShowingPrivacyWebView = true
            }) {
                Text("Privacy")
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Show terms web view
                isShowingTermsWebView = true
            }) {
                Text("Terms")
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
            
            Spacer()
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Restore TODO: Restore - Needs more testing
                restore()
            }) {
                Text("Restore")
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
        }
        .foregroundStyle(Colors.elementBackgroundColor)
        .opacity(0.5)
    }
    
    var closeButton: some View {
        Button(action: {
            DispatchQueue.main.async {
                isShowing = false
            }
        }) {
            Text(Image(systemName: "xmark"))
                .font(isCloseButtonEnlarged ? .custom(Constants.FontName.medium, size: 24.0) : .custom(Constants.FontName.body, size: 17.0))
        }
        .foregroundStyle(Colors.elementBackgroundColor)
        .opacity(isCloseButtonEnlarged ? 0.6 : 0.2)
        .padding()
    }
    
    func restore() {
        Task {
            do {
                // Do restore TODO: Needs more testing
                try await ultraViewModel.restore()
                
                // Do success haptic
                HapticHelper.doSuccessHaptic()
            } catch {
                // TODO: Handle errors
                print("Error restoring purchases in UltraView... \(error)")
                
                // Do warning haptic
                HapticHelper.doWarningHaptic()
                
                // Show error restoring purchases alert
                alertShowingErrorRestoringPurchases = true
            }
        }
    }
    
    func purchase() {
        // Unwrap tappedPeriod
        guard let tappedPeriod = tappedPeriod else {
            // TODO: Handle errors
            print("Could not unwrap tappedPeriod in purchase in UltraView!")
            return
        }
        
        Task {
            // Purchase
            await ultraViewModel.purchase(subscriptionPeriod: tappedPeriod)
            
            // If premium on complete, do success haptic and dismiss
            if premiumUpdater.isPremium {
                // Do success haptic
                HapticHelper.doSuccessHaptic()
                
                // Dismiss
                DispatchQueue.main.async {
                    isShowing = false
                }
            }
        }
    }
    
    
}

#Preview {
    VStack {
        
    }
    .sheet(isPresented: .constant(true)) {
        UltraView(
            premiumUpdater: PremiumUpdater(),
            isShowing: .constant(true))
    }
}
