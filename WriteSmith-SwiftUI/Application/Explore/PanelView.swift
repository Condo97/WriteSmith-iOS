//
//  PanelView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct PanelView: View {
    
    @ObservedObject var premiumUpdater: PremiumUpdater
    @ObservedObject var remainingUpdater: RemainingUpdater
    @State var panel: Panel
    
    
    @StateObject private var exploreChatGenerator = ExploreChatGenerator()
    
    @State private var finalizedPrompt: String?
    
    @State private var alertShowingEmptyRequiredFields: Bool = false
    
    @State private var isShowingExploreChatsDisplayView: Bool = false
    @State private var isShowingInterstitial: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack(spacing: 16.0) {
                    if !premiumUpdater.isPremium {
                        BannerView(bannerID: Keys.Ads.Banner.panelView)
                    }
                    
                    HeaderPanelComponentView(
                        imageName: $panel.imageName,
                        emoji: $panel.emoji,
                        title: $panel.title,
                        description: $panel.description)
                    .padding()
                    
                    ForEach($panel.components) { $component in
                        switch component.type {
                        case .dropdown(let dropdownPanelComponent):
                            DropdownPanelComponentView(
                                titleText: component.titleText,
                                selectedOption: dropdownPanelComponent.placeholderUnwrapped,
                                options: dropdownPanelComponent.options,
                                promptPrefix: component.promptPrefix,
                                required: component.requiredUnwrapped,
                                finalizedPrompt: $component.finalizedPrompt)
                            .padding([.leading, .trailing])
                        case .textField(let textFieldPanelComponent):
                            TextFieldPanelComponentView(
                                titleText: component.titleText,
                                placeholder: textFieldPanelComponent.placeholderUnwrapped,
                                multiline: textFieldPanelComponent.multilineUnwrapped,
                                promptPrefix: component.promptPrefix,
                                required: component.requiredUnwrapped,
                                finalizedPrompt: $component.finalizedPrompt)
                            .padding([.leading, .trailing])
                        }
                    }
                }
                .padding(.bottom, 190)
            }
            
            VStack(spacing: 0.0) {
                Spacer()
                
                ZStack {
                    KeyboardDismissingButton(action: {
                        // Ensure finalizedPrompt can be unwrapped, otherwise show empty fields alert and return
                        guard let finalizedPrompt = finalizedPrompt else {
                            alertShowingEmptyRequiredFields = true
                            return
                        }
                        
                        // Show interstitial if not premium
                        if !premiumUpdater.isPremium {
                            isShowingInterstitial = true
                        }
                        
                        // Generate
                        Task {
                            do {
                                try await exploreChatGenerator.generateExplore(
                                    input: finalizedPrompt,
                                    isPremium: premiumUpdater.isPremium,
                                    remainingUpdater: remainingUpdater)
                            }
                        }
                    }) {
                        ZStack {
                            HStack {
                                Spacer()
                                Text("Generate...")
                                    .font(.custom(Constants.FontName.heavy, size: 24.0))
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                
                                if exploreChatGenerator.isLoading {
                                    ProgressView()
                                        .tint(Colors.elementTextColor)
                                } else {
                                    Text(Image(systemName: "chevron.right"))
                                        .font(.custom(Constants.FontName.body, size: 17.0))
                                }
                            }
                        }
                    }
                    .foregroundStyle(Colors.elementTextColor)
                    .padding()
                    .background(Colors.buttonBackground)
                    .opacity(finalizedPrompt == nil ? 0.4 : 1.0)
                    .background(Colors.background)
                    .clipShape(RoundedRectangle(cornerRadius: 24.0))
                    .padding()
                    .padding(.bottom, 40)
                    .disabled(finalizedPrompt == nil)
                }
                .background(
                    VStack(spacing: 0.0) {
                        LinearGradient(colors: [Colors.background, .clear], startPoint: .bottom, endPoint: .top)
                            .frame(height: 40.0)
                        Colors.background
                    }
                        .ignoresSafeArea()
                )
            }
        }
        .background(Colors.background)
        .background(
            InterstitialView(interstitialID: Keys.Ads.Interstitial.panelView, disabled: $premiumUpdater.isPremium, isPresented: $isShowingInterstitial))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
            
            if !premiumUpdater.isPremium {
                UltraToolbarItem(
                    premiumUpdater: premiumUpdater,
                    remainingUpdater: remainingUpdater)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Colors.elementBackgroundColor, for: .navigationBar)
        .keyboardDismissingTextFieldToolbar("Done", color: Colors.buttonBackground)
        .onChange(of: panel.components) { newComponents in
            updateFinalizedPrompt()
        }
        .onReceive(exploreChatGenerator.$generatedChats, perform: { generatedChats in
            if generatedChats.count > 0, !generatedChats[0].chat.isEmpty {
                isShowingExploreChatsDisplayView = true
            }
        })
        .navigationDestination(isPresented: $isShowingExploreChatsDisplayView, destination: {
            ExploreChatsDisplayView(
                premiumUpdater: premiumUpdater,
                remainingUpdater: remainingUpdater,
                chats: $exploreChatGenerator.generatedChats)
        })
        .alert("Empty Required Fields", isPresented: $alertShowingEmptyRequiredFields, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }) {
            Text("Please make sure all required fields have text.")
        }
    }
    
    private func updateFinalizedPrompt() {
        // TODO: I don't think that it's using the "prompt" text when creating the finalized prompt, so maybe that's something that needs to be fixed?
        
        let commaSeparator = ", "
        
        // Build completeFinalizedPrompt, ensuring that all required values' finalizedPrompts are not nil and return
        var completeFinalizedPrompt = ""
        for i in 0..<panel.components.count {
            let component = panel.components[i]
            
            // Unswrap finalizedPrompt, otherwise either return nil or continue if required or not
            guard let finalizedPrompt = component.finalizedPrompt, !finalizedPrompt.isEmpty else {
                // If required set finalizedPrompt to nil and return
                if component.requiredUnwrapped {
                    finalizedPrompt = nil
                    return
                }
                
                // Otherwise, continue
                continue
            }
            
            // Append to completeFinalizedPrompt
            completeFinalizedPrompt.append(finalizedPrompt)
            
            // If not the last index in panel.components, append the comma separator
            if i < panel.components.count - 1 {
                completeFinalizedPrompt.append(commaSeparator)
            }
        }
        
        // Ensure completeFinalizedPrompt is not empty, otherwise set to nil and return TODO: Is this good here? Maybe I need to rework this function? I don't think it's great to be using nil and switching between nil and empty.. it should just be one state, the empty state I think, not the nil state ever..
        guard !completeFinalizedPrompt.isEmpty else {
            finalizedPrompt = nil
            return
        }
        
        finalizedPrompt = completeFinalizedPrompt
        
        print("Finalized Prompt: \(finalizedPrompt)")
    }
    
}

#Preview {
    NavigationStack {
        PanelView(
            premiumUpdater: PremiumUpdater(),
            remainingUpdater: RemainingUpdater(),
            panel: Panel(
                emoji: "🎶",
                title: "The title",
                description: "The description",
                prompt: "The prompt",
                components: [
                    PanelComponent(
                        type: .dropdown(
                            DropdownPanelComponent(
                                placeholder: "Placeholder",
                                options: [
                                    "Option 1",
                                    "Option 2",
                                    "Option 3"
                                ])),
                        titleText: "Title Text",
                        detailTitle: "Detail Title",
                        detailText: "Detail Text",
                        promptPrefix: "Prompt Prefix",
                        required: true),
                    PanelComponent(
                        type: .textField(
                            TextFieldPanelComponent(
                                placeholder: "placeholder"
                            )),
                        titleText: "Text Field Title Text",
                        detailTitle: "Text Field Detail Title",
                        detailText: "Text Field Detail Text",
                        promptPrefix: "Text Field Prompt Prefix",
                        required: false),
                    PanelComponent(
                        type: .dropdown(
                            DropdownPanelComponent(
                                placeholder: "Placeholder",
                                options: [
                                    "Option 1",
                                    "Option 2",
                                    "Option 3"
                                ])),
                        titleText: "Title Text",
                        detailTitle: "Detail Title",
                        detailText: "Detail Text",
                        promptPrefix: "Prompt Prefix",
                        required: true),
                    PanelComponent(
                        type: .textField(
                            TextFieldPanelComponent(
                                placeholder: "placeholder"
                            )),
                        titleText: "Text Field Title Text",
                        detailTitle: "Text Field Detail Title",
                        detailText: "Text Field Detail Text",
                        promptPrefix: "Text Field Prompt Prefix",
                        required: false),
                    PanelComponent(
                        type: .dropdown(
                            DropdownPanelComponent(
                                placeholder: "Placeholder",
                                options: [
                                    "Option 1",
                                    "Option 2",
                                    "Option 3"
                                ])),
                        titleText: "Title Text",
                        detailTitle: "Detail Title",
                        detailText: "Detail Text",
                        promptPrefix: "Prompt Prefix",
                        required: true),
                    PanelComponent(
                        type: .textField(
                            TextFieldPanelComponent(
                                placeholder: "placeholder"
                            )),
                        titleText: "Text Field Title Text",
                        detailTitle: "Text Field Detail Title",
                        detailText: "Text Field Detail Text",
                        promptPrefix: "Text Field Prompt Prefix",
                        required: false),
                    PanelComponent(
                        type: .dropdown(
                            DropdownPanelComponent(
                                placeholder: "Placeholder",
                                options: [
                                    "Option 1",
                                    "Option 2",
                                    "Option 3"
                                ])),
                        titleText: "Title Text",
                        detailTitle: "Detail Title",
                        detailText: "Detail Text",
                        promptPrefix: "Prompt Prefix",
                        required: true),
                    PanelComponent(
                        type: .textField(
                            TextFieldPanelComponent(
                                placeholder: "placeholder"
                            )),
                        titleText: "Text Field Title Text",
                        detailTitle: "Text Field Detail Title",
                        detailText: "Text Field Detail Text",
                        promptPrefix: "Text Field Prompt Prefix",
                        required: false)
                ]))
        .background(Colors.background)
    }
}
