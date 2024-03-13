//
//  ConversationView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import SwiftUI

struct ConversationView: View {
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    @EnvironmentObject var remainingUpdater: RemainingUpdater
    @EnvironmentObject var faceAnimationUpdater: FaceAnimationUpdater
    
    @Binding var isShowingGPTModelSelectionView: Bool
    @Binding var pushToLatestConversationOrClose: Bool
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @SectionedFetchRequest<String, Conversation>(
        sectionIdentifier: \.dateSection,
        sortDescriptors: [NSSortDescriptor(keyPath: \Conversation.latestChatDate, ascending: false)],
        animation: .default)
    private var sectionedConversations
    
    @State private var transitionToNewConversation: Bool = false
    
    @State private var isShowingSettingsView: Bool = false
    
    @State private var presentingConversation: Conversation?
    var isShowingPresentingConversation: Binding<Bool> {
        Binding(
            get: {
                presentingConversation != nil
            },
            set: { newValue in
                if !newValue {
                    presentingConversation = nil
                }
            })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0.0) {
                    if !premiumUpdater.isPremium {
                        BannerView(bannerID: Keys.Ads.Banner.conversationView)
                    }
                    
                    List {
                        newChatButton
                        
                        conversationList
                    }
                    .navigationDestination(isPresented: isShowingPresentingConversation, destination: {
                        if let presentingConversation = presentingConversation {
                            ChatView(
                                conversation: presentingConversation,
                                isShowingGPTModelSelectionView: $isShowingGPTModelSelectionView,
                                transitionToNewConversation: $transitionToNewConversation,
                                shouldShowFirstConversationChats: sectionedConversations.count == 0 || (sectionedConversations.count == 1 && sectionedConversations[0].count <= 1)
                            )
                        }
                    })
                }
            }
            .scrollContentBackground(.hidden)
            .background(Colors.background)
            .navigationTitle("Chats")
            .navigationDestination(isPresented: $isShowingSettingsView, destination: {
                SettingsView()
            })
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                SettingsToolbarItem(
                    elementColor: .constant(Colors.elementTextColor),
                    placement: .topBarLeading,
                    tightenLeadingSpacing: true,
                    tightenTrailingSpacing: true,
                    action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Show Settings View
                        isShowingSettingsView = true
                })
                
                ShareToolbarItem(
                    elementColor: .constant(Colors.elementTextColor),
                    placement: .topBarLeading,
                    tightenLeadingSpacing: true)
                
                LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
                
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                        .tint(Colors.elementTextColor)
                        .font(.custom(Constants.FontName.black, size: 17.0))
                        .padding(.top, 4)
                        .padding(.trailing, premiumUpdater.isPremium ? 0.0 : -12.0)
                        .onTapGesture {
                            // Do light haptic
                            HapticHelper.doLightHaptic()
                        }
                }
                
                if !premiumUpdater.isPremium {
                    UltraToolbarItem()
                }
            }
            .toolbarBackground(Colors.topBarBackgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onChange(of: pushToLatestConversationOrClose, perform: { value in
                if value {
                    pushToLatestConversationOrCloseIfNecessary()
                }
            })
            .onChange(of: transitionToNewConversation, perform: { value in
                if value {
                    Task {
                        await transitionToNewConversationIfNecessary()
                    }
                }
            })
            .onAppear {
                pushToLatestConversationOrCloseIfNecessary()
        }
        }
    }
    
    var newChatButton: some View {
        Button(action: {
            // Do light haptic
            HapticHelper.doLightHaptic()
            
            // Create and save conversation, setting to presentingConversation
            let conversation = Conversation(context: viewContext)
            conversation.conversationID = Constants.defaultConversationID
            conversation.behavior = nil
            
            
            DispatchQueue.main.async {
                do {
                    try viewContext.save()
                } catch {
                    print("Error saving new Conversation in ConversationView... \(error)")
                }
                
                presentingConversation = conversation
            }
        }) {
            HStack {
                Spacer()
                Text("New Chat...")
                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                    .foregroundStyle(Colors.buttonBackground)
                    .padding()
                Spacer()
            }
            .background(
                ZStack {
                    let cornerRadius = UIConstants.cornerRadius
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Colors.buttonBackground, lineWidth: 2.0)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Colors.elementTextColor)
                })
        }
        .buttonStyle(.plain)
        .listRowBackground(
            Color.clear
        )
        .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
        .bounceable()
    }
    
    var conversationList: some View {
        ForEach(sectionedConversations) { conversations in
            Section {
                ForEach(conversations) { conversation in
                    if let latestChatText = conversation.latestChatText {
                        ConversationRow(
                            conversation: conversation,
                            action: {
                                // Do light haptic
                                HapticHelper.doLightHaptic()
                                
                                // Set presentingConversation to show conversation
                                presentingConversation = conversation
                            })
                    }
                }
                .onDelete(perform: { indexSet in
                    Task {
                        for index in indexSet {
                            viewContext.delete(conversations[index])
                        }
                        
                        do {
                            try await viewContext.perform {
                                try viewContext.save()
                            }
                        } catch {
                            // TODO: Handle errors
                            print("Error saving viewContext after deleting conversatoins in ConversationView... \(error)")
                        }
                    }
                })
            }
        }
    }
    
    func pushToLatestConversationOrCloseIfNecessary() {
        // Defer setting pushToLatestConversationOrClose to false to ensure it is set when the function completes
        defer {
            pushToLatestConversationOrClose = false
        }
        
        // Ensure that pushToLatestConversationOrClose is true, otherwise return
        guard pushToLatestConversationOrClose else {
            return
        }
        
        // If presentingConversation is nil push to latest, otherwise set to nil
        if presentingConversation == nil {
            do {
                // Get the conversation to push to
                if let conversationToPushTo = try ConversationResumingManager.getConversation(in: viewContext) {
                    // Set presentingConversation to conversationToPushTo and return
                    presentingConversation = conversationToPushTo
                    
                    return
                }
            } catch {
                // TODO: Handle errors if necessary
            }
            
            // If it has gotten here, there is no conversation to push to so append a new conversation and set it to that
            let conversation = Conversation(context: viewContext)
            conversation.conversationID = Constants.defaultConversationID
            conversation.behavior = nil
            
            // TODO: This doesn't all necessarily have to be on the main thread, it can also be a Task with just the saving done on the MainActor 
            DispatchQueue.main.async {
                do {
                    try viewContext.save()
                } catch {
                    // TODO: Handle errors
                    print("Error saving viewContext in ConversationView... \(error)")
                }
                
                // Set presentingConversation to conversation TODO: Should this be in the do ?
                self.presentingConversation = conversation
                
                // Set ConversationResumingManager conversation
                do {
                    try ConversationResumingManager.setConversation(conversation, in: viewContext)
                } catch {
                    // TODO: Handle errors
                    print("Error obtaining permanent ID for Conversation in ConversationView... \(error)")
                }
            }
        } else {
            presentingConversation = nil
        }
    }
    
    func transitionToNewConversationIfNecessary() async {
        // TODO: Make this better, it's a little jumpy in the transition
        
        // Defer setting transitionToNewConversation to false to ensure it is always set when the function completes
        defer {
            transitionToNewConversation = false
        }
        
        // Ensure transitionToNewConversation is true, otherwise return
        guard transitionToNewConversation else {
            return
        }
        
        let conversation = Conversation(context: viewContext)
        conversation.conversationID = Constants.defaultConversationID
        conversation.behavior = nil
        
        await MainActor.run {
            do {
                try viewContext.save()
            } catch {
                // TODO: Handle errors
                print("Error saving new conversation in ConversationView... \(error)")
            }
        
            // Set animations to false and set presentingConversation to nil
            UIView.setAnimationsEnabled(false)
            
            presentingConversation = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: {
            // Set animations to false and set presentingConversation to conversation
            UIView.setAnimationsEnabled(false)
            
            presentingConversation = conversation
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            // Set animations back to true
            UIView.setAnimationsEnabled(true)
        })
    }
    
}

#Preview {
    
//    for i in 0..<10 {
//        let conversation = Conversation(context: CDClient.mainManagedObjectContext)
//        conversation.latestChatText = "Test\(i)"
//        
//        try? CDClient.mainManagedObjectContext.save()
//    }
    
    return NavigationStack {
        ConversationView(
            isShowingGPTModelSelectionView: .constant(false),
            pushToLatestConversationOrClose: .constant(false))
    }
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    .environmentObject(PremiumUpdater())
    .environmentObject(RemainingUpdater())
    .environmentObject(FaceAnimationUpdater())
}
