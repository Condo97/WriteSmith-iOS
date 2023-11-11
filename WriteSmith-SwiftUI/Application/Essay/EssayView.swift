//
//  EssayView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/25/23.
//

import SwiftUI

struct EssayView: View {
    
    @ObservedObject var premiumUpdater: PremiumUpdater
    @ObservedObject var remainingUpdater: RemainingUpdater
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Essay.date, ascending: false)],
        animation: .default)
    private var essays: FetchedResults<Essay>
    
    @StateObject private var essayGenerator: EssayChatGenerator = EssayChatGenerator()
    
    @State private var essayFieldText: String = ""
    @State private var essaysShowing: [Essay] = []
    
    @State private var isDisplayingEssayLoadingView: Bool = false
    
    @State private var isShowingInterstitial: Bool = false
    @State private var isShowingSettingsView: Bool = false
    @State private var isShowingUltraView: Bool = false
    
    @State private var alertShowingFreeEssayLimitReached: Bool = false
    
    private let freeEssayLimit = Constants.defaultFreeEssayCap
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                if !premiumUpdater.isPremium {
                    BannerView(bannerID: Keys.Ads.Banner.chatView)
                }
                
                Spacer(minLength: 20.0)
                
                prompt
                
                if isDisplayingEssayLoadingView {
                    loadingView
                }
                
                Spacer(minLength: 20.0)
                
                essaysList
                
                if !premiumUpdater.isPremium {
                    EssayPromoRowView(isShowingUltraView: $isShowingUltraView)
                }
                
                Spacer(minLength: 120.0)
            }
        }
        .background(Colors.background)
        .keyboardDismissingTextFieldToolbar("Done", color: Colors.buttonBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            SettingsToolbarItem(
                elementColor: .constant(Colors.elementTextColor),
                placement: .topBarLeading,
                tightenLeadingSpacing: true,
                tightenTrailingSpacing: true,
                action: {
                isShowingSettingsView = true
            })
            
            ShareToolbarItem(
                elementColor: .constant(Colors.elementTextColor),
                placement: .topBarLeading,
                tightenLeadingSpacing: true)
            
            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
            
            if !premiumUpdater.isPremium {
                UltraToolbarItem(
                    premiumUpdater: premiumUpdater,
                    remainingUpdater: remainingUpdater)
            }
        }
        .toolbarBackground(Colors.topBarBackgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .ultraViewPopover(isPresented: $isShowingUltraView, premiumUpdater: premiumUpdater)
        .navigationDestination(isPresented: $isShowingSettingsView, destination: {
            SettingsView(premiumUpdater: premiumUpdater)
        })
        .onReceive(essayGenerator.$isLoading) { isLoading in
            withAnimation {
                isDisplayingEssayLoadingView = isLoading
            }
        }
    }
    
    var prompt: some View {
        HStack {
            // Essay Text Field
            TextField("", text: $essayFieldText)
                .placeholder(when: essayFieldText.isEmpty, placeholder: {
                    Text("Enter a prompt...")
                })
//                .dismissOnReturn()
                .toolbarBackground(Colors.elementTextColor)
                .font(.custom(Constants.FontName.medium, size: 20.0))
                .foregroundStyle(Colors.elementTextColor)
            
            // Generate Essay Button
            KeyboardDismissingButton(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // If not premium and has reached free essay limit, show alert and return
                if !premiumUpdater.isPremium && essays.count >= freeEssayLimit {
                    alertShowingFreeEssayLimitReached = true
                    return
                }
                
                // Show interstitial if not premium
                if !premiumUpdater.isPremium {
                    isShowingInterstitial = true
                }
                
                // Generate essay
                Task {
                    do {
                        try await essayGenerator.generateEssay(
                            input: essayFieldText,
                            isPremium: premiumUpdater.isPremium,
                            remainingUpdater: remainingUpdater,
                            in: viewContext)
                    } catch {
                        // TODO: Handle errors
                        print("Error generating essay in EssayView... \(error)")
                    }
                }
            }) {
                Image(systemName: "square.and.pencil.circle.fill")
            }
            .font(.custom(Constants.FontName.body, size: 40.0))
            .foregroundStyle(Colors.elementTextColor)
            .disabled(essayFieldText.isEmpty)
            .opacity(essayFieldText.isEmpty ? 0.4 : 1.0)
            .alert("Limit Reached", isPresented: $alertShowingFreeEssayLimitReached, actions: {
                Button("Close", role: nil, action: {
                    
                })
                
                Button("Start Free Trial", role: .cancel, action: {
                    isShowingUltraView = true
                })
            }) {
                Text("Please upgrade to create more essays. Get unlimited essays, chats & more for Free for 3 Days!")
            }
        }
        .padding([.top, .bottom], 10)
        .padding([.leading, .trailing])
        .background(Colors.elementBackgroundColor)
        .background(
            InterstitialView(interstitialID: Keys.Ads.Interstitial.essayView, disabled: $premiumUpdater.isPremium, isPresented: $isShowingInterstitial))
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding([.leading, .trailing])
    }
    
    var loadingView: some View {
        ZStack {
            PulsatingDotsView(count: 3, size: 20.0)
                .foregroundStyle(Colors.elementBackgroundColor)
        }
        .padding(8)
        .background(Colors.elementTextColor)
        .clipShape(RoundedRectangle(cornerRadius: 24.0))
        .padding(8)
    }
    
    var essaysList: some View {
        ForEach(essays) { essay in
            if essay.prompt != nil, essay.essay != nil && !essay.essay!.isEmpty || essay.editedEssay != nil && !essay.editedEssay!.isEmpty {
                let isExpanded: Binding = Binding(
                    get: {
                        essaysShowing.contains(essay)
                    },
                    set: { isExpanded in
                        if isExpanded {
                            if !essaysShowing.contains(essay) {
                                essaysShowing.append(essay)
                            }
                        } else {
                            essaysShowing.removeAll(where: {$0 == essay})
                        }
                    })
                
                EssayRowView(
                    premiumUpdater: premiumUpdater,
                    essay: essay,
                    isGenerating: essayGenerator.isLoading || essayGenerator.isGenerating,
                    isExpanded: isExpanded)
            }
        }
    }
    
}

#Preview {
    
    let essay = Essay(context: CDClient.mainManagedObjectContext)
    
    essay.prompt = "this is the essay's prompt"
    essay.essay = "this is the essay\nasdfasdfasdfasdf\nasdf\n\n\n\n\n\n\\n\n\n\n\\n and it's long"
    essay.date = Date()
    
    try? CDClient.mainManagedObjectContext.save()
    
    return EssayView(
        premiumUpdater: PremiumUpdater(),
        remainingUpdater: RemainingUpdater())
        .background(Colors.background)
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
}
