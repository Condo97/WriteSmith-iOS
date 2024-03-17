//
//  UltraView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import StoreKit
import SwiftUI
import TenjinSDK

struct UltraView: View {
    
    @Binding var restoreOnAppear: Bool
    @Binding var isShowing: Bool
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    
    
    private enum ShowingPromoRow {
        case gptVision
        case gptIntelligence
        case unlimitedMessages
        case removeAds
    }
    
    private enum ValidSubscriptions {
        // The subscription id represented as an enum
        case weekly
        case monthly
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedSubscription: ValidSubscriptions = .weekly
    
    @State private var isSmallSize: Bool = false
    
    @State private var isCloseButtonEnlarged: Bool = false
    
    @State private var alertShowingErrorRestoringPurchases: Bool = false
    @State private var alertShowingErrorLoading: Bool = false
    
    @State private var isShowingTermsWebView: Bool = false
    @State private var isShowingPrivacyWebView: Bool = false
    
    @State private var isLoadingPurchase: Bool = false
    
    @State private var faceAnimationViewRepresentable = FaceAnimationViewRepresentable(
        frame: CGRect(x: 0, y: 0, width: faceAnimationViewDiameter, height: faceAnimationViewDiameter),
        faceImageName: Constants.ImageName.faceImageName,
        color: UIColor(Colors.elementBackgroundColor),
        startAnimation: SmileCenterFaceAnimation(duration: 0.0))
    
    @State private var showingPromoRow: ShowingPromoRow? = initialShowingRow
    
    private let smallSizeMaxHeight: CGFloat = 680.0
    
    private let closeButtonEnlargeDelay = 2.0
    
    private static let initialShowingRow: ShowingPromoRow = .gptVision
    private let initialShowingRow = initialShowingRow
    
    private static let faceAnimationViewDiameter = 100.0
    private let faceAnimationViewDiameter = faceAnimationViewDiameter
    
    private let faceAnimationUpdater: FaceAnimationUpdater = FaceAnimationUpdater(faceAnimationViewRepresentable: nil)
    
    private let currencyNumberFormatter: NumberFormatter = {
        let currencyNumberFormatter = NumberFormatter()
        currencyNumberFormatter.numberStyle = .decimal
        currencyNumberFormatter.maximumFractionDigits = 2
        currencyNumberFormatter.minimumFractionDigits = 2
        return currencyNumberFormatter
    }()
    
    private var freeTrialSelected: Binding<Bool> {
        Binding(
            get: {
                selectedSubscription == .weekly
            }, set: { newValue in
                if newValue {
                    selectedSubscription = .weekly
                } else {
                    selectedSubscription = .monthly
                }
            })
    }
    
    
    init(restoreOnAppear: Binding<Bool> = .constant(false), isShowing: Binding<Bool>) {
        self._restoreOnAppear = restoreOnAppear
        self._isShowing = isShowing
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        isSmallSize = geometry.size.height < smallSizeMaxHeight
                        
                        if isSmallSize {
                           // Set showingPromoRow to nil
                           showingPromoRow = nil
                        } else {
                            // Set showingPromoRow to initialShowingRow
                            showingPromoRow = initialShowingRow
                        }
                    }
            }
            
            Color.clear
                .overlay(alignment: .bottom) {
                    VStack {
                        Spacer()
                        
                        topImagesAndPromoText
                            .padding(.bottom, 4)
//                            .ignoresSafeArea()
                        
                        Spacer()
                        
                        featuresList
                            .frame(maxWidth: 380)
                            .padding([.leading, .trailing])
                            .padding(.bottom, 8)
                        
                        Spacer()
                        
                        purchaseButtons
                            .padding([.leading, .trailing])
//                            .padding(.bottom, 4)
                        
                        iapRequiredButtons
                            .padding([.leading, .trailing])
//                            .padding(.bottom)
                        
                    }
//                    .ignoresSafeArea()
            }
//            .ignoresSafeArea()
            
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        closeButton
//                            .padding()
                            .padding(.top, -24.0)
                    }
                    
                    Spacer()
                }
//                .ignoresSafeArea()
            }
        }
        .background(Colors.background)
        .alert("Error restoring purchases...", isPresented: $alertShowingErrorRestoringPurchases, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }) {
            Text("You can try tapping on the subsciption you previously purchased. Apple will prevent a double charge.")
        }
        .onAppear {
            faceAnimationUpdater.faceAnimationViewRepresentable = faceAnimationViewRepresentable
            
            faceAnimationUpdater.setFaceIdleAnimationToSmile()
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
        HStack(spacing: 8.0) {
            let faceAnimationViewContainerInset = 20.0
            
            ZStack {
                faceAnimationViewRepresentable
                    .frame(width: faceAnimationViewDiameter, height: faceAnimationViewDiameter)
            }
            .frame(width: faceAnimationViewDiameter + faceAnimationViewContainerInset, height: faceAnimationViewDiameter + faceAnimationViewContainerInset)
            
            VStack {
                Text("Meet Your AI")
                    .font(.custom(Constants.FontName.black, size: 28.0))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text("Powered by **GPT-4 + Vision**")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .foregroundStyle(colorScheme == .dark ? Colors.elementBackgroundColor : Colors.text)
            .frame(height: 60.0)
            .padding([.leading, .trailing], 8)
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 40.0)
                .fill(Colors.elementTextColor)
        )
        .padding([.leading, .trailing])
//        VStack(spacing: 0.0) {
//            Image(colorScheme == .dark ? Constants.ImageName.Ultra.ultraDark : Constants.ImageName.Ultra.ultraLight)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .opacity(colorScheme == .dark ? 0.8 : 1.0)
////                .frame(maxWidth: horizontalSizeClass == .regular ? 200.0 : .infinity)
//
//            Text("Unlimited Messages, Image Chats & More!")
//                .font(.custom(Constants.FontName.bodyOblique, size: 17.0))
//                .foregroundStyle(Colors.elementBackgroundColor)
//                .padding(.top, -28)
//        }
    }
    
    var featuresList: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation(.spring) {
                    if showingPromoRow == .gptVision {
                        showingPromoRow = nil
                    } else {
                        showingPromoRow = .gptVision
                    }
                }
            }) {
                HStack(alignment: showingPromoRow == .gptVision ? .top : .center) {
                    Text(Image(systemName: "eye.fill"))
                        .font(.custom(Constants.FontName.body, size: 24.0))
                    
                    VStack(alignment: .leading) {
                        Text("GPT-4 + Vision")
                            .font(.custom(Constants.FontName.black, size: 20.0))
                        +
                        Text(" *NEW!*")
                            .font(.custom(Constants.FontName.body, size: 20.0))
                        
                        if showingPromoRow == .gptVision {
                            Text("Send images in chats! Get help on visual problems. Ask questions about an object. Let AI see into your world.")
                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                .multilineTextAlignment(.leading)
                                .opacity(0.6)
                                .transition(.opacity)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                    }
                    
                    Spacer(minLength: 0.0)
                    
                    Text(Image(systemName: showingPromoRow == .gptVision ? "chevron.up" : "chevron.down"))
                        .font(.custom(Constants.FontName.body, size: 14.0))
                        .foregroundStyle(Colors.elementBackgroundColor)
                        .opacity(0.8)
                        .padding(.top, showingPromoRow == .gptVision ? 8 : 0)
                        .padding(.trailing, 8)
                }
            }
            .padding(6)
//            .background(
//                RoundedRectangle(cornerRadius: 14.0)
//                    .stroke(Colors.elementBackgroundColor, lineWidth: 1.0)
//                    .opacity(0.4)
//            )
            
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation(.spring) {
                    if showingPromoRow == .gptIntelligence {
                        showingPromoRow = nil
                    } else {
                        showingPromoRow = .gptIntelligence
                    }
                }
            }) {
                HStack(alignment: showingPromoRow == .gptIntelligence ? .top : .center) {
                    if #available(iOS 17.0, *) {
                        Text(Image(systemName: "brain.fill"))
                            .font(.custom(Constants.FontName.body, size: 24.0))
                    } else {
                        Text(Image(systemName: "brain"))
                            .font(.custom(Constants.FontName.body, size: 24.0))
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Unlock")
                            .font(.custom(Constants.FontName.black, size: 20.0))
                        +
                        Text(" GPT-4 Intelligence")
                            .font(.custom(Constants.FontName.body, size: 20.0))
                        
                        if showingPromoRow == .gptIntelligence {
                            Text("Incredibly smart. Trained on books, research, websites and more. Updated for 2024.")
                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                .multilineTextAlignment(.leading)
                                .opacity(0.6)
                                .transition(.opacity)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Spacer(minLength: 0.0)
                    
                    Text(Image(systemName: showingPromoRow == .gptIntelligence ? "chevron.up" : "chevron.down"))
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(Colors.elementBackgroundColor)
                        .opacity(0.8)
                        .padding(.top, showingPromoRow == .gptIntelligence ? 8 : 0)
                        .padding(.trailing, 8)
                }
            }
            .padding(6)
//            .background(
//                RoundedRectangle(cornerRadius: 14.0)
//                    .stroke(Colors.elementBackgroundColor, lineWidth: 1.0)
//                    .opacity(0.4)
//            )
            
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation(.spring) {
                    if showingPromoRow == .unlimitedMessages {
                        showingPromoRow = nil
                    } else {
                        showingPromoRow = .unlimitedMessages
                    }
                }
            }) {
                HStack(alignment: showingPromoRow == .unlimitedMessages ? .top : .center) {
                    ZStack {
                        Text(Image(systemName: "bubble.left.fill"))
                            .font(.custom(Constants.FontName.body, size: 28.0))
                        Text(Image(systemName: "infinity"))
                            .font(.custom(Constants.FontName.medium, size: 14.0))
                            .foregroundStyle(Colors.background)
                            .padding(.top, -4.4)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Unlimited")
                            .font(.custom(Constants.FontName.black, size: 20.0))
                        +
                        Text(" Messages")
                            .font(.custom(Constants.FontName.body, size: 20.0))
                        
                        if showingPromoRow == .unlimitedMessages {
                            Text("Keep chats going longer. Ask follow up questions. Dive deep into any subject.")
                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                .multilineTextAlignment(.leading)
                                .opacity(0.6)
                                .transition(.opacity)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Spacer(minLength: 0.0)
                    
                    Text(Image(systemName: showingPromoRow == .unlimitedMessages ? "chevron.up" : "chevron.down"))
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(Colors.elementBackgroundColor)
                        .opacity(0.8)
                        .padding(.top, showingPromoRow == .unlimitedMessages ? 8 : 0)
                        .padding(.trailing, 8)
                }
            }
            .padding(4)
            
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation(.spring) {
                    if showingPromoRow == .removeAds {
                        showingPromoRow = nil
                    } else {
                        showingPromoRow = .removeAds
                    }
                }
            }) {
                HStack(alignment: showingPromoRow == .removeAds ? .top : .center) {
                    ZStack {
                        Text(Image(systemName: "circle.slash.fill"))
                            .font(.custom(Constants.FontName.body, size: 28.0))
                        Text("ADs")
                            .font(.custom(Constants.FontName.black, size: 12.0))
                            .padding(.top, -2)
                            .foregroundStyle(Colors.background)
                        Text(Image(systemName: "circle.slash"))
                            .font(.custom(Constants.FontName.body, size: 28.0))
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Remove")
                            .font(.custom(Constants.FontName.black, size: 20.0))
                        +
                        Text(" Ads")
                            .font(.custom(Constants.FontName.body, size: 20.0))
                        
                        if showingPromoRow == .removeAds {
                            Text("Nothing to clutter your experience.")
                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                .multilineTextAlignment(.leading)
                                .opacity(0.6)
                                .transition(.opacity)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                
                Spacer(minLength: 0.0)
                
                Text(Image(systemName: showingPromoRow == .removeAds ? "chevron.up" : "chevron.down"))
                    .font(.custom(Constants.FontName.body, size: 17.0))
                    .foregroundStyle(Colors.elementBackgroundColor)
                    .opacity(0.8)
                    .padding(.top, showingPromoRow == .removeAds ? 8 : 0)
                    .padding(.trailing, 8)
            }
            .padding(4)
        }
        .foregroundStyle(Colors.text)
        .multilineTextAlignment(.leading)
    }
    
    var purchaseButtons: some View {
        VStack(spacing: 8.0) {
            if let weeklyProduct = productUpdater.weeklyProduct {
                if let introductaryOffer = weeklyProduct.subscription?.introductoryOffer {
                    ZStack {
                        HStack {
                            Toggle(isOn: freeTrialSelected) {
                                        let introductaryText = introductaryOffer.price == 0.0 ? "Enable Free Trial" : "Enable Special Offer"
                                        
                                        Text(introductaryText)
                                            .font(.custom(Constants.FontName.medium, size: 20.0))
                                    
                            }
                            .onTapGesture {
                                HapticHelper.doMediumHaptic()
                            }
                            .tint(Colors.elementBackgroundColor)
                            .foregroundStyle(Colors.elementBackgroundColor)
                        }
                    }
                    .padding(8)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 14.0)
                                .fill(Colors.userChatTextColor)
                        }
                    )
                }
            }
            
            Text("Directly Supports the Developer - Cancel Anytime")
                .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                .padding(.bottom, -6)
                .opacity(0.6)
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Set selected subscription to weekly
                selectedSubscription = .weekly
            }) {
                ZStack {
                    if let weeklyProduct = productUpdater.weeklyProduct {
                        let productPriceString = currencyNumberFormatter.string(from: weeklyProduct.price as NSNumber) ?? weeklyProduct.displayPrice
                        
                        HStack {
                            if let introductaryOffer = weeklyProduct.subscription?.introductoryOffer {
                                let offerPriceString = introductaryOffer.price == 0.99 ? "99¢" : currencyNumberFormatter.string(from: introductaryOffer.price as NSNumber) ?? introductaryOffer.displayPrice
                                
                                if introductaryOffer.paymentMode == .freeTrial || introductaryOffer.price == 0.0 {
                                    // Free Trial
                                    let durationString = "\(introductaryOffer.period.value)"
                                    let unitString = switch introductaryOffer.period.unit {
                                    case .day: "Day"
                                    case .week: "Week"
                                    case .month: "Month"
                                    case .year: "Year"
                                    @unknown default: ""
                                    }
                                    
                                    Text("\(durationString) \(unitString) Trial")
                                        .font(.custom(Constants.FontName.black, size: 20.0))
                                    +
                                    Text(" - Then \(productPriceString) / week")
                                        .font(.custom(Constants.FontName.body, size: 19.0))
                                } else {
                                    // Discount
                                    VStack(alignment: .leading, spacing: 0.0) {
                                        Text("Special Offer - \(offerPriceString) / week")
                                            .font(.custom(Constants.FontName.black, size: 20.0))
                                        let durationString = introductaryOffer.periodCount.word
                                        
                                        Text("for \(durationString) weeks, then \(productPriceString) / week")
                                            .font(.custom(Constants.FontName.bodyOblique, size: 19.0))
                                            .minimumScaleFactor(0.69)
                                            .lineLimit(1)
                                    }
                                }
                                
                            } else {
                                Text("\(productPriceString) / week")
                                    .font(.custom(Constants.FontName.black, size: 20.0))
                            }
                            
                            
                            
                            Spacer()
                            
                            Text(Image(systemName: selectedSubscription == .weekly ? "checkmark.circle.fill" : "circle"))
                                .font(.custom(Constants.FontName.body, size: 28.0))
                                .padding([.top, .bottom], -6)
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("Blank")
                                .opacity(0.0)
                            Spacer()
                        }
                    }
                    
                    if isLoadingPurchase && selectedSubscription == .weekly {
                        HStack {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
            .padding(12)
            .foregroundStyle(Colors.elementBackgroundColor)
            .tint(.white)
            .background(
                ZStack {
                    let cornerRadius = UIConstants.cornerRadius
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Colors.userChatTextColor)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Colors.elementBackgroundColor, lineWidth: selectedSubscription == .weekly ? 2.0 : 1.0)
                }
            )
            .opacity(isLoadingPurchase ? 0.4 : 1.0)
            .disabled(isLoadingPurchase)
            .bounceable(disabled: isLoadingPurchase)
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Set selected subscription to monthly
                selectedSubscription = .monthly
            }) {
                ZStack {
                    if let monthlyProduct = productUpdater.monthlyProduct {
                        let productPriceString = currencyNumberFormatter.string(from: monthlyProduct.price as NSNumber) ?? monthlyProduct.displayPrice
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 0.0) {
                                Text("Monthly - \(productPriceString) / month")
                                    .font(.custom(Constants.FontName.body, size: 20.0))
                                Text("That's 30% Off Weekly!")
                                    .font(.custom(Constants.FontName.black, size: 14.0))
                                    .padding(.top, -2)
                            }
                            
                            Spacer()
                            
                            Text(Image(systemName: selectedSubscription == .monthly ? "checkmark.circle.fill" : "circle"))
                                .font(.custom(Constants.FontName.body, size: 28.0))
                                .padding([.top, .bottom], -6)
                        }
                        
                        if isLoadingPurchase && selectedSubscription == .monthly {
                            HStack {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                }
            }
            .padding(12)
            .foregroundStyle(Colors.elementBackgroundColor)
            .tint(Colors.elementBackgroundColor)
            .background(
                ZStack {
                    let cornerRadius = UIConstants.cornerRadius
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Colors.userChatTextColor)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Colors.elementBackgroundColor, lineWidth: selectedSubscription == .monthly ? 2.0 : 1.0)
                }
            )
            .opacity(isLoadingPurchase ? 0.4 : 1.0)
            .disabled(isLoadingPurchase)
            .bounceable(disabled: isLoadingPurchase)
            
            Button(action: {
                // Do medium haptic
                HapticHelper.doMediumHaptic()
                
                // Purchase
                purchase()
            }) {
                ZStack {
                    Text("Continue...")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                    
                    HStack {
                        Spacer()
                        
                        Text(Image(systemName: "chevron.right"))
                    }
                }
            }
            .padding(18)
            .foregroundStyle(Colors.elementTextColor)
            .background(Colors.elementBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            .opacity(isLoadingPurchase ? 0.4 : 1.0)
            .disabled(isLoadingPurchase)
            .bounceable(disabled: isLoadingPurchase)
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
                .font(isCloseButtonEnlarged ? .custom(Constants.FontName.medium, size: 20.0) : .custom(Constants.FontName.body, size: 17.0))
        }
        .foregroundStyle(Colors.elementBackgroundColor)
        .opacity(isCloseButtonEnlarged ? 0.4 : 0.1)
        .padding()
    }
    
    func restore() {
        Task {
            do {
                // Do restore TODO: Needs more testing
                try await restore()
                
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
//        // Unwrap tappedPeriod
//        guard let selectedSubscription = selectedSubscription else {
//            // TODO: Handle errors
//            print("Could not unwrap tappedPeriod in purchase in UltraView!")
//            return
//        }
        // Get product to purchase
        let product = switch selectedSubscription {
        case .weekly:
            productUpdater.weeklyProduct
        case .monthly:
            productUpdater.monthlyProduct
        }
        
        // Unwrap product
        guard let product = product else {
            // TODO: Handle errors
            print("Could not unwrap product in purchase in UltraView!")
            
            return
        }
        
        // Set isLoadingPurchase to true
        isLoadingPurchase = true
        
        Task {
            defer {
                isLoadingPurchase = false
            }
            
            // Unwrap authToken
            guard let authToken = try? await AuthHelper.ensure() else {
                // If the authToken is nil, show an error alert that the app can't connect to the server and return
                alertShowingErrorLoading = true
                return
            }
            
            // Purchase
            let transaction: StoreKit.Transaction
            do {
                transaction = try await IAPManager.purchase(product)
            } catch {
                // TODO: Handle errors
                print("Error purchasing product in UltraView... \(error)")
                return
            }
            
            // Update tenjin
            TenjinSDK.transaction(
                withProductName: product.displayName,
                andCurrencyCode: "USD",
                andQuantity: 1,
                andUnitPrice: NSDecimalNumber(decimal: product.price))
            
            // Register the transaction ID with the server
            try await premiumUpdater.registerTransaction(authToken: authToken, transactionID: transaction.id)

            
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
    
    func restore() async throws {
        defer {
            DispatchQueue.main.async {
                isLoadingPurchase = false
            }
        }
        
        await MainActor.run {
            isLoadingPurchase = true
        }
        
        try await AppStore.sync()
    }
    
    
}

#Preview {
    VStack {
        
    }
    .fullScreenCover(isPresented: .constant(true)) {
        UltraView(isShowing: .constant(true))
    }
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
}


////
////  UltraView.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 10/27/23.
////
//
//import SwiftUI
//
//struct UltraView: View {
//    
//    @ObservedObject var premiumUpdater: PremiumUpdater
//    @Binding var restoreOnAppear: Bool
//    @Binding var isShowing: Bool
//    
//    
//    private enum ShowingPromoRow {
//        case gptVision
//        case gptIntelligence
//        case unlimitedMessages
//        case removeAds
//    }
//    
//    @Environment(\.colorScheme) private var colorScheme
//    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
//    
//    @ObservedObject private var ultraViewModel: UltraViewModel
//    
//    @State private var selectedSubscription: UltraViewModel.ValidSubscriptions = .weekly
//    
//    @State private var isSmallSize: Bool = false
//    
//    @State private var isCloseButtonEnlarged: Bool = false
//    
//    @State private var alertShowingErrorRestoringPurchases: Bool = false
//    
//    @State private var isShowingTermsWebView: Bool = false
//    @State private var isShowingPrivacyWebView: Bool = false
//    
//    @State private var faceAnimationViewRepresentable = FaceAnimationViewRepresentable(
//        frame: CGRect(x: 0, y: 0, width: faceAnimationViewDiameter, height: faceAnimationViewDiameter),
//        faceImageName: Constants.ImageName.faceImageName,
//        color: UIColor(Colors.elementBackgroundColor),
//        startAnimation: SmileCenterFaceAnimation(duration: 0.0))
//    
//    @State private var showingPromoRow: ShowingPromoRow? = initialShowingRow
//    
//    private let smallSizeMaxHeight: CGFloat = 680.0
//    
//    private let closeButtonEnlargeDelay = 2.0
//    
//    private static let initialShowingRow: ShowingPromoRow = .gptVision
//    private let initialShowingRow = initialShowingRow
//    
//    private static let faceAnimationViewDiameter = 100.0
//    private let faceAnimationViewDiameter = faceAnimationViewDiameter
//    
//    private let faceAnimationUpdater: FaceAnimationUpdater = FaceAnimationUpdater(faceAnimationViewRepresentable: nil)
//    
//    private var freeTrialSelected: Binding<Bool> {
//        Binding(
//            get: {
//                selectedSubscription == .weekly
//            }, set: { newValue in
//                if newValue {
//                    selectedSubscription = .weekly
//                } else {
//                    selectedSubscription = .monthly
//                }
//            })
//    }
//    
//    
//    init(premiumUpdater: PremiumUpdater, restoreOnAppear: Binding<Bool> = .constant(false), isShowing: Binding<Bool>) {
//        self.premiumUpdater = premiumUpdater
//        self._restoreOnAppear = restoreOnAppear
//        self._isShowing = isShowing
//        
//        self.ultraViewModel = UltraViewModel(premiumUpdater: premiumUpdater)
//    }
//    
//    var body: some View {
//        ZStack {
//            GeometryReader { geometry in
//                Color.clear
//                    .onAppear {
//                        isSmallSize = geometry.size.height < smallSizeMaxHeight
//                        
//                        if isSmallSize {
//                           // Set showingPromoRow to nil
//                           showingPromoRow = nil
//                        } else {
//                            // Set showingPromoRow to initialShowingRow
//                            showingPromoRow = initialShowingRow
//                        }
//                    }
//            }
//            
//            Color.clear
//                .overlay(alignment: .bottom) {
//                    VStack {
//                        Spacer()
//                        
//                        topImagesAndPromoText
//                            .padding(.bottom, 4)
////                            .ignoresSafeArea()
//                        
//                        Spacer()
//                        
//                        featuresList
//                            .frame(maxWidth: 380)
//                            .padding([.leading, .trailing])
//                            .padding(.bottom, 8)
//                        
//                        Spacer()
//                        
//                        purchaseButtons
//                            .padding([.leading, .trailing])
////                            .padding(.bottom, 4)
//                        
//                        iapRequiredButtons
//                            .padding([.leading, .trailing])
////                            .padding(.bottom)
//                        
//                    }
////                    .ignoresSafeArea()
//            }
////            .ignoresSafeArea()
//            
//            ZStack {
//                VStack {
//                    HStack {
//                        Spacer()
//                        
//                        closeButton
////                            .padding()
//                            .padding(.top, -24.0)
//                    }
//                    
//                    Spacer()
//                }
////                .ignoresSafeArea()
//            }
//        }
//        .background(Colors.background)
//        .alert("Error restoring purchases...", isPresented: $alertShowingErrorRestoringPurchases, actions: {
//            Button("Close", role: .cancel, action: {
//                
//            })
//        }) {
//            Text("You can try tapping on the subsciption you previously purchased. Apple will prevent a double charge.")
//        }
//        .onAppear {
//            faceAnimationUpdater.faceAnimationViewRepresentable = faceAnimationViewRepresentable
//            
//            faceAnimationUpdater.setFaceIdleAnimationToSmile()
//        }
//        .onAppear {
//            // Start restore logic if restoreOnAppear is true, and set restoreOnAppear to false once started
//            if restoreOnAppear {
//                restore()
//                
//                restoreOnAppear = false
//            }
//            
//            // Start close button enlarge timer
//            Timer.scheduledTimer(withTimeInterval: closeButtonEnlargeDelay, repeats: false, block: { timer in
//                withAnimation {
//                    isCloseButtonEnlarged = true
//                }
//            })
//        }
//        .fullScreenCover(isPresented: $isShowingTermsWebView) {
//            NavigationStack {
//                VStack {
//                    WebView(url: URL(string: "\(HTTPSConstants.chitChatServerStaticFiles)\(HTTPSConstants.termsAndConditions)")!)
//                        .toolbar {
//                            CloseToolbarItem(isPresented: $isShowingTermsWebView)
//                            
//                            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
//                        }
//                        .toolbarBackground(Colors.elementBackgroundColor, for: .navigationBar)
//                        .toolbarBackground(.visible, for: .navigationBar)
//                        .navigationBarTitleDisplayMode(.inline)
//                        .background(Colors.background)
//                        .ignoresSafeArea()
//                }
//            }
//        }
//        .fullScreenCover(isPresented: $isShowingPrivacyWebView) {
//            NavigationStack {
//                VStack {
//                    WebView(url: URL(string: "\(HTTPSConstants.chitChatServerStaticFiles)\(HTTPSConstants.privacyPolicy)")!)
//                        .toolbar {
//                            CloseToolbarItem(isPresented: $isShowingPrivacyWebView)
//                            
//                            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
//                        }
//                        .toolbarBackground(Colors.elementBackgroundColor, for: .navigationBar)
//                        .toolbarBackground(.visible, for: .navigationBar)
//                        .navigationBarTitleDisplayMode(.inline)
//                        .background(Colors.background)
//                        .ignoresSafeArea()
//                }
//            }
//        }
//    }
//    
//    var topImagesAndPromoText: some View {
//        HStack(spacing: 8.0) {
//            let faceAnimationViewContainerInset = 20.0
//            
//            ZStack {
//                faceAnimationViewRepresentable
//                    .frame(width: faceAnimationViewDiameter, height: faceAnimationViewDiameter)
//            }
//            .frame(width: faceAnimationViewDiameter + faceAnimationViewContainerInset, height: faceAnimationViewDiameter + faceAnimationViewContainerInset)
//            
//            VStack {
//                Text("Meet Your AI")
//                    .font(.custom(Constants.FontName.black, size: 28.0))
//                    .minimumScaleFactor(0.5)
//                    .lineLimit(1)
//                
//                Text("Powered by GPT-4 + Vision")
//                    .font(.custom(Constants.FontName.body, size: 17.0))
//                    .minimumScaleFactor(0.5)
//                    .lineLimit(1)
//            }
//            .frame(height: 60.0)
//            .padding([.leading, .trailing], 8)
//            
//            Spacer()
//        }
//        .background(
//            RoundedRectangle(cornerRadius: 40.0)
//                .fill(Colors.foreground)
//        )
//        .padding([.leading, .trailing])
////        VStack(spacing: 0.0) {
////            Image(colorScheme == .dark ? Constants.ImageName.Ultra.ultraDark : Constants.ImageName.Ultra.ultraLight)
////                .resizable()
////                .aspectRatio(contentMode: .fill)
////                .opacity(colorScheme == .dark ? 0.8 : 1.0)
//////                .frame(maxWidth: horizontalSizeClass == .regular ? 200.0 : .infinity)
////            
////            Text("Unlimited Messages, Image Chats & More!")
////                .font(.custom(Constants.FontName.bodyOblique, size: 17.0))
////                .foregroundStyle(Colors.elementBackgroundColor)
////                .padding(.top, -28)
////        }
//    }
//    
//    var featuresList: some View {
//        VStack(alignment: .leading, spacing: 8.0) {
//            Button(action: {
//                HapticHelper.doLightHaptic()
//                
//                withAnimation(.spring) {
//                    if showingPromoRow == .gptVision {
//                        showingPromoRow = nil
//                    } else {
//                        showingPromoRow = .gptVision
//                    }
//                }
//            }) {
//                HStack(alignment: showingPromoRow == .gptVision ? .top : .center) {
//                    Text(Image(systemName: "eye.fill"))
//                        .font(.custom(Constants.FontName.body, size: 24.0))
//                    
//                    VStack(alignment: .leading) {
//                        Text("GPT-4 + Vision")
//                            .font(.custom(Constants.FontName.black, size: 20.0))
//                        +
//                        Text(" *NEW!*")
//                            .font(.custom(Constants.FontName.body, size: 20.0))
//                        
//                        if showingPromoRow == .gptVision {
//                            Text("Send images in chats! Get help on visual problems. Ask questions about an object. Let AI see into your world.")
//                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
//                                .multilineTextAlignment(.leading)
//                                .opacity(0.6)
//                                .transition(.opacity)
//                                .fixedSize(horizontal: false, vertical: true)
//                        }
//                        
//                    }
//                    
//                    Spacer(minLength: 0.0)
//                    
//                    Text(Image(systemName: showingPromoRow == .gptVision ? "chevron.up" : "chevron.down"))
//                        .font(.custom(Constants.FontName.body, size: 14.0))
//                        .foregroundStyle(Colors.elementBackgroundColor)
//                        .opacity(0.8)
//                        .padding(.top, showingPromoRow == .gptVision ? 8 : 0)
//                        .padding(.trailing, 8)
//                }
//            }
//            .padding(6)
////            .background(
////                RoundedRectangle(cornerRadius: 14.0)
////                    .stroke(Colors.elementBackgroundColor, lineWidth: 1.0)
////                    .opacity(0.4)
////            )
//            
//            Button(action: {
//                HapticHelper.doLightHaptic()
//                
//                withAnimation(.spring) {
//                    if showingPromoRow == .gptIntelligence {
//                        showingPromoRow = nil
//                    } else {
//                        showingPromoRow = .gptIntelligence
//                    }
//                }
//            }) {
//                HStack(alignment: showingPromoRow == .gptIntelligence ? .top : .center) {
//                    Text(Image(systemName: "brain.fill"))
//                        .font(.custom(Constants.FontName.body, size: 24.0))
//                    
//                    VStack(alignment: .leading) {
//                        Text("Unlock")
//                            .font(.custom(Constants.FontName.black, size: 20.0))
//                        +
//                        Text(" GPT-4 Intelligence")
//                            .font(.custom(Constants.FontName.body, size: 20.0))
//                        
//                        if showingPromoRow == .gptIntelligence {
//                            Text("Incredibly smart. Trained on books, research, websites and more. Updated for 2023.")
//                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
//                                .multilineTextAlignment(.leading)
//                                .opacity(0.6)
//                                .transition(.opacity)
//                                .fixedSize(horizontal: false, vertical: true)
//                        }
//                    }
//                    
//                    Spacer(minLength: 0.0)
//                    
//                    Text(Image(systemName: showingPromoRow == .gptIntelligence ? "chevron.up" : "chevron.down"))
//                        .font(.custom(Constants.FontName.body, size: 17.0))
//                        .foregroundStyle(Colors.elementBackgroundColor)
//                        .opacity(0.8)
//                        .padding(.top, showingPromoRow == .gptIntelligence ? 8 : 0)
//                        .padding(.trailing, 8)
//                }
//            }
//            .padding(6)
////            .background(
////                RoundedRectangle(cornerRadius: 14.0)
////                    .stroke(Colors.elementBackgroundColor, lineWidth: 1.0)
////                    .opacity(0.4)
////            )
//            
//            Button(action: {
//                HapticHelper.doLightHaptic()
//                
//                withAnimation(.spring) {
//                    if showingPromoRow == .unlimitedMessages {
//                        showingPromoRow = nil
//                    } else {
//                        showingPromoRow = .unlimitedMessages
//                    }
//                }
//            }) {
//                HStack(alignment: showingPromoRow == .unlimitedMessages ? .top : .center) {
//                    ZStack {
//                        Text(Image(systemName: "bubble.fill"))
//                            .font(.custom(Constants.FontName.body, size: 28.0))
//                        Text(Image(systemName: "infinity"))
//                            .font(.custom(Constants.FontName.medium, size: 14.0))
//                            .foregroundStyle(Colors.background)
//                            .padding(.top, -4.4)
//                    }
//                    
//                    VStack(alignment: .leading) {
//                        Text("Unlimited")
//                            .font(.custom(Constants.FontName.black, size: 20.0))
//                        +
//                        Text(" Messages")
//                            .font(.custom(Constants.FontName.body, size: 20.0))
//                        
//                        if showingPromoRow == .unlimitedMessages {
//                            Text("Keep chats going longer. Ask follow up questions. Dive deep into any subject.")
//                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
//                                .multilineTextAlignment(.leading)
//                                .opacity(0.6)
//                                .transition(.opacity)
//                                .fixedSize(horizontal: false, vertical: true)
//                        }
//                    }
//                    
//                    Spacer(minLength: 0.0)
//                    
//                    Text(Image(systemName: showingPromoRow == .unlimitedMessages ? "chevron.up" : "chevron.down"))
//                        .font(.custom(Constants.FontName.body, size: 17.0))
//                        .foregroundStyle(Colors.elementBackgroundColor)
//                        .opacity(0.8)
//                        .padding(.top, showingPromoRow == .unlimitedMessages ? 8 : 0)
//                        .padding(.trailing, 8)
//                }
//            }
//            .padding(4)
////            .background(
////                RoundedRectangle(cornerRadius: 14.0)
////                    .stroke(Colors.elementBackgroundColor, lineWidth: 1.0)
////                    .opacity(0.4)
////            )
//            
//            Button(action: {
//                HapticHelper.doLightHaptic()
//                
//                withAnimation(.spring) {
//                    if showingPromoRow == .removeAds {
//                        showingPromoRow = nil
//                    } else {
//                        showingPromoRow = .removeAds
//                    }
//                }
//            }) {
//                HStack(alignment: showingPromoRow == .removeAds ? .top : .center) {
//                    ZStack {
//                        Text(Image(systemName: "circle.slash.fill"))
//                            .font(.custom(Constants.FontName.body, size: 28.0))
//                        Text("ADs")
//                            .font(.custom(Constants.FontName.black, size: 12.0))
//                            .padding(.top, -2)
//                            .foregroundStyle(Colors.background)
//                        Text(Image(systemName: "circle.slash"))
//                            .font(.custom(Constants.FontName.body, size: 28.0))
//                    }
//                    
//                    VStack(alignment: .leading) {
//                        Text("Remove")
//                            .font(.custom(Constants.FontName.black, size: 20.0))
//                        +
//                        Text(" Ads")
//                            .font(.custom(Constants.FontName.body, size: 20.0))
//                        
//                        if showingPromoRow == .removeAds {
//                            Text("Nothing to clutter your experience.")
//                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
//                                .multilineTextAlignment(.leading)
//                                .opacity(0.6)
//                                .transition(.opacity)
//                                .fixedSize(horizontal: false, vertical: true)
//                        }
//                    }
//                }
//                
//                Spacer(minLength: 0.0)
//                
//                Text(Image(systemName: showingPromoRow == .removeAds ? "chevron.up" : "chevron.down"))
//                    .font(.custom(Constants.FontName.body, size: 17.0))
//                    .foregroundStyle(Colors.elementBackgroundColor)
//                    .opacity(0.8)
//                    .padding(.top, showingPromoRow == .removeAds ? 8 : 0)
//                    .padding(.trailing, 8)
//            }
//            .padding(4)
//        }
//        .foregroundStyle(Colors.text)
//        .multilineTextAlignment(.leading)
//    }
//    
//    var purchaseButtons: some View {
//        VStack(spacing: 8.0) {
//            ZStack {
//                HStack {
//                    Toggle(isOn: freeTrialSelected) {
//                        Text("Enable Free Trial")
//                            .font(.custom(Constants.FontName.medium, size: 20.0))
//                    }
//                    .onTapGesture {
//                        HapticHelper.doMediumHaptic()
//                    }
//                    .tint(Colors.userChatBubbleColor)
//                    .foregroundStyle(Colors.userChatBubbleColor)
//                }
//            }
//            .padding(8)
//            .background(
//                ZStack {
//                    RoundedRectangle(cornerRadius: 14.0)
//                        .fill(Colors.userChatTextColor)
//                }
//            )
//            
//            Text("Directly Supports the Developer - Cancel Anytime")
//                .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
//                .padding(.bottom, -6)
//                .opacity(0.6)
//            
//            Button(action: {
//                // Do light haptic
//                HapticHelper.doLightHaptic()
//                
//                // Set selected subscription to weekly
//                selectedSubscription = .weekly
//            }) {
//                ZStack {
//                    HStack {
//                        Text("3 Day Trial")
//                            .font(.custom(Constants.FontName.black, size: 20.0))
//                        +
//                        Text(" - Then 6.95 / week")
//                            .font(.custom(Constants.FontName.body, size: 19.0))
//                        
//                        Spacer()
//                        
//                        Text(Image(systemName: selectedSubscription == .weekly ? "checkmark.circle.fill" : "circle"))
//                            .font(.custom(Constants.FontName.body, size: 28.0))
//                            .padding([.top, .bottom], -6)
//                    }
//                    
//                    if ultraViewModel.isLoading && selectedSubscription == .weekly {
//                        HStack {
//                            Spacer()
//                            ProgressView()
//                        }
//                    }
//                }
//            }
//            .padding(12)
//            .foregroundStyle(Colors.userChatBubbleColor)
//            .tint(.white)
//            .background(
//                ZStack {
//                    let cornerRadius = UIConstants.cornerRadius
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .fill(colorScheme == .dark ? Colors.textOnBackgroundColor : Colors.foreground)
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .stroke(Colors.buttonBackground, lineWidth: selectedSubscription == .weekly ? 2.0 : 1.0)
//                }
//            )
//            .opacity(ultraViewModel.isLoading ? 0.4 : 1.0)
//            .disabled(ultraViewModel.isLoading)
//            .bounceable(disabled: ultraViewModel.isLoading)
//            
//            Button(action: {
//                // Do light haptic
//                HapticHelper.doLightHaptic()
//                
//                // Set selected subscription to monthly
//                selectedSubscription = .monthly
//            }) {
//                ZStack {
//                    HStack {
//                        VStack(alignment: .leading, spacing: 0.0) {
//                            Text("Monthly - 19.99 / month")
//                                .font(.custom(Constants.FontName.body, size: 20.0))
//                            Text("That's 30% Off Weekly!")
//                                .font(.custom(Constants.FontName.black, size: 14.0))
//                                .padding(.top, -2)
//                        }
//                        
//                        Spacer()
//                        
//                        Text(Image(systemName: selectedSubscription == .monthly ? "checkmark.circle.fill" : "circle"))
//                            .font(.custom(Constants.FontName.body, size: 28.0))
//                            .padding([.top, .bottom], -6)
//                    }
//                    
//                    if ultraViewModel.isLoading && selectedSubscription == .monthly {
//                        HStack {
//                            Spacer()
//                            ProgressView()
//                        }
//                    }
//                }
//            }
//            .padding(12)
//            .foregroundStyle(Colors.buttonBackground)
//            .tint(Colors.buttonBackground)
//            .background(
//                ZStack {
//                    let cornerRadius = UIConstants.cornerRadius
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .fill(colorScheme == .dark ? Colors.textOnBackgroundColor : Colors.foreground)
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .stroke(Colors.buttonBackground, lineWidth: selectedSubscription == .monthly ? 2.0 : 1.0)
//                }
//            )
//            .opacity(ultraViewModel.isLoading ? 0.4 : 1.0)
//            .disabled(ultraViewModel.isLoading)
//            .bounceable(disabled: ultraViewModel.isLoading)
//            
//            Button(action: {
//                // Do medium haptic
//                HapticHelper.doMediumHaptic()
//                
//                // Purchase
//                purchase()
//            }) {
//                ZStack {
//                    Text("Continue...")
//                        .font(.custom(Constants.FontName.heavy, size: 20.0))
//                    
//                    HStack {
//                        Spacer()
//                        
//                        Text(Image(systemName: "chevron.right"))
//                    }
//                }
//            }
//            .padding()
//            .foregroundStyle(Colors.elementTextColor)
//            .background(Colors.buttonBackground)
//            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
//            .opacity(ultraViewModel.isLoading ? 0.4 : 1.0)
//            .disabled(ultraViewModel.isLoading)
//            .bounceable(disabled: ultraViewModel.isLoading)
//        }
//    }
//    
//    var iapRequiredButtons: some View {
//        HStack {
//            Button(action: {
//                // Do light haptic
//                HapticHelper.doLightHaptic()
//                
//                // Show privacy web view
//                isShowingPrivacyWebView = true
//            }) {
//                Text("Privacy")
//                    .font(.custom(Constants.FontName.body, size: 12.0))
//            }
//            
//            Button(action: {
//                // Do light haptic
//                HapticHelper.doLightHaptic()
//                
//                // Show terms web view
//                isShowingTermsWebView = true
//            }) {
//                Text("Terms")
//                    .font(.custom(Constants.FontName.body, size: 12.0))
//            }
//            
//            Spacer()
//            
//            Button(action: {
//                // Do light haptic
//                HapticHelper.doLightHaptic()
//                
//                // Restore TODO: Restore - Needs more testing
//                restore()
//            }) {
//                Text("Restore")
//                    .font(.custom(Constants.FontName.body, size: 12.0))
//            }
//        }
//        .foregroundStyle(Colors.elementBackgroundColor)
//        .opacity(0.5)
//    }
//    
//    var closeButton: some View {
//        Button(action: {
//            DispatchQueue.main.async {
//                isShowing = false
//            }
//        }) {
//            Text(Image(systemName: "xmark"))
//                .font(isCloseButtonEnlarged ? .custom(Constants.FontName.medium, size: 20.0) : .custom(Constants.FontName.body, size: 17.0))
//        }
//        .foregroundStyle(Colors.elementBackgroundColor)
//        .opacity(isCloseButtonEnlarged ? 0.4 : 0.1)
//        .padding()
//    }
//    
//    func restore() {
//        Task {
//            do {
//                // Do restore TODO: Needs more testing
//                try await ultraViewModel.restore()
//                
//                // Do success haptic
//                HapticHelper.doSuccessHaptic()
//            } catch {
//                // TODO: Handle errors
//                print("Error restoring purchases in UltraView... \(error)")
//                
//                // Do warning haptic
//                HapticHelper.doWarningHaptic()
//                
//                // Show error restoring purchases alert
//                alertShowingErrorRestoringPurchases = true
//            }
//        }
//    }
//    
//    func purchase() {
////        // Unwrap tappedPeriod
////        guard let selectedSubscription = selectedSubscription else {
////            // TODO: Handle errors
////            print("Could not unwrap tappedPeriod in purchase in UltraView!")
////            return
////        }
//        
//        Task {
//            // Purchase
//            await ultraViewModel.purchase(subscriptionPeriod: selectedSubscription)
//            
//            // If premium on complete, do success haptic and dismiss
//            if premiumUpdater.isPremium {
//                // Do success haptic
//                HapticHelper.doSuccessHaptic()
//                
//                // Dismiss
//                DispatchQueue.main.async {
//                    isShowing = false
//                }
//            }
//        }
//    }
//    
//    
//}
//
//#Preview {
//    VStack {
//        
//    }
//    .fullScreenCover(isPresented: .constant(true)) {
//        UltraView(
//            premiumUpdater: PremiumUpdater(),
//            isShowing: .constant(true))
//    }
//}
