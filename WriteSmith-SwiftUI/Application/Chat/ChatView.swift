//
//  ChatView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import CoreData
import SwiftUI

struct ChatView: View, KeyboardReadable {
    
    @Binding private var isShowingGPTModelSelectionView: Bool
    @Binding private var transitionToNewConversation: Bool
    @State private var shouldShowFirstConversationChats: Bool
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var productUpdater: ProductUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    @EnvironmentObject private var faceAnimationUpdater: FaceAnimationUpdater
    
    @State private var chatGenerator: ConversationChatGenerator = ConversationChatGenerator()
    
    
    private let chatsBottomPadding: CGFloat = 140.0
    
    @FetchRequest<Chat> private var chats: FetchedResults<Chat>
    
    @State private var isDisplayingLoadingChatBubble: Bool = false
    
    @State private var alertShowingUpgradeForUnlimitedChats: Bool = false
    
    @State private var isShowingUltraView: Bool = false
    
    @State private var isKeyboardVisible: Bool = false
    
    @State private var conversation: Conversation
    
    @State private var currentlyDraggedChat: Chat?
    
    
    init(conversation: Conversation, isShowingGPTModelSelectionView: Binding<Bool>, transitionToNewConversation: Binding<Bool>, shouldShowFirstConversationChats: Bool) {
        self._chats = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: false)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation.objectID),
            animation: .default)
        
        self._conversation = State(initialValue: conversation)
        self._isShowingGPTModelSelectionView = isShowingGPTModelSelectionView
        self._transitionToNewConversation = transitionToNewConversation
        self._shouldShowFirstConversationChats = State(initialValue: shouldShowFirstConversationChats)
        
        if !shouldShowFirstConversationChats && conversation.chats?.count == 0 {
            // If there are no chats, add the initial one
            DispatchQueue.main.async {
                do {
                    // TODO: This uses CDClient mainManagedObjectContext instead of viewContext, is there a better way to do this?
                    try withAnimation(.none) {
                        try ChatCDHelper.appendChat(
                            sender: .ai,
                            text: FirstChats.getRandomFirstChat(),
                            to: conversation,
                            in: CDClient.mainManagedObjectContext)
                    }
                } catch {
                    // TODO: Handle errors
                    print("Error appending chat in ChatView... \(error)")
                }
            }
        }
        
        // Set ConversationResumingManager conversation TODO: This uses CDClient mainManagedObjectContext
        do {
            try ConversationResumingManager.setConversation(conversation, in: CDClient.mainManagedObjectContext)
        } catch {
            // TODO: Handle errors
            print("Error obtaining permanent ID for conversation in ConversationView... \(error)")
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0.0) {
                if !premiumUpdater.isPremium {
                    BannerView(bannerID: Keys.Ads.Banner.chatView)
                }
                
                ZStack {
                    
                    VStack(spacing: 0.0) {
                        ScrollView(.vertical) {
                            
                            Spacer(minLength: premiumUpdater.isPremium ? 50.0 : 120.0)
                            VStack {
                                Spacer()
                                
                                if isDisplayingLoadingChatBubble {
                                    loadingChatBubble
                                }
                                
                                chatList
                                
                                Spacer(minLength: 60.0)
                            }
                        }
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if abs(gesture.translation.height) >= 20 {
                                        withAnimation {
                                            currentlyDraggedChat = nil
                                        }
                                    }
                                })
                        .scrollIndicators(.never)
                        .rotationEffect(.degrees(180))
                        
                        Spacer()
                        
                        entry
                            .padding(.top, premiumUpdater.isPremium ? -50.0 /* This is the height of the linear gradient in entry */ : /* This is just some number that seems to work lol */ -120.0)
                    }
                    
                    // GPT selector
                    gptSelector
                    
                }
                .padding(.bottom, isKeyboardVisible ? 8.0 : 48.0)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.visible, for: .navigationBar)
                .toolbar {
                    LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
                    
                    AddChatToolbarItem(elementColor: .constant(Colors.elementTextColor), trailingPadding: premiumUpdater.isPremium ? 0.0 : -12.0, action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Transition to new conversation
                        transitionToNewConversation = true
                    })
                    
                    if !premiumUpdater.isPremium {
                        UltraToolbarItem()
                    }
                }
                .toolbarBackground(Colors.topBarBackgroundColor, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                
            }
            .background(Colors.background)
        }
        .environmentObject(chatGenerator)
        .task {
            // Ensure there are no chats, otherwise return
            guard chats.count == 0 else {
                return
            }
            
            // Show the first conversation chats
            do {
                // TODO: This uses CDClient mainManagedObjectContext instead of viewContext, is there a better way to do this?
                try await showFirstConversationChats(to: conversation, in: CDClient.mainManagedObjectContext)
            } catch {
                // TODO: Handle errors
                print("Error showing first conversation chats in ChatView... \(error)")
            }
        }
        .onReceive(chatGenerator.$isLoading, perform: { isLoading in
            if isLoading {
                withAnimation {
                    isDisplayingLoadingChatBubble = isLoading
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                    isDisplayingLoadingChatBubble = false
                })
            }
        })
        .onReceive(keyboardPublisher, perform: { value in
            withAnimation {
                isKeyboardVisible = value
            }
        })
        .ultraViewPopover(isPresented: $isShowingUltraView)
        //        .keyboardDismissingTextFieldToolbar("Done", color: Colors.buttonBackground)
        .scrollDismissesKeyboard(.immediately)
        .alert("Upgrade for FREE", isPresented: $alertShowingUpgradeForUnlimitedChats, actions: {
            Button("Cancel", role: nil, action: {
                
            })
            
            Button("Start Free Trial", role: .cancel, action: {
                isShowingUltraView = true
            })
        }) {
            Text("Please upgrade for unlimited chats. Tap Start Free Trial to get Unlimited + GPT-4 for FREE!")
        }
    }
    
    // MARK: - Local Views
    
    var loadingChatBubble: some View {
        ChatBubbleView(
            sender: .ai,
            canCopy: false,
            canDrag: false,
            isDragged: .constant(false),
            content: {
                PulsatingDotsView(count: 4, size: 16.0)
                    .foregroundStyle(Colors.elementBackgroundColor)
                    .padding(.leading, 5)
                    .padding(.trailing, 9)
            })
        .rotationEffect(.degrees(180))
        .padding(.bottom, 8)
        .padding([.leading, .trailing])
        //                                    .animation(.easeInOut(duration: 5.0), value: chatGenerator.isLoading)
        .transition(.moveUp)
    }
    
    var chatList: some View {
        ForEach(chats) { chat in
            if chat.text != nil || chat.imageData != nil, let chatSender = chat.sender, let sender = Sender(rawValue: chatSender) {
                let isDragged = Binding(
                    get: {
                        currentlyDraggedChat == chat
                    },
                    set: { value in
                        currentlyDraggedChat = value ? chat : nil
                    })
                
                HStack {
                    ChatBubbleView(
                        sender: sender,
                        canCopy: chat.text != nil,
                        canDrag: true,
                        isDragged: isDragged,
                        content: {
                            ZStack {
                                if let text = chat.text {
                                    VStack(alignment: sender == .user ? .trailing : .leading) {
                                        // If there is text and an image, display the image on top
                                        if let imageData = chat.imageData, let image = UIImage(data: imageData) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxHeight: 80.0)
                                                .clipShape(RoundedRectangle(cornerRadius: 12.0))
                                            
                                            Divider()
                                                .background(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                                        }
                                        
                                        // Display the text
                                        HStack {
                                            Text(text)
                                                .font(.custom(sender == .user ? Constants.FontName.heavy : Constants.FontName.body, size: 14.0))
                                                .frame(minWidth: 28.0)
                                        }
                                        .foregroundStyle(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                                        .padding([.top, .bottom], 14)
                                        .padding([.leading, .trailing], 14)
                                    }
                                } else if let imageData = chat.imageData, let image = UIImage(data: imageData) {
                                    // Display the image
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 200.0)
                                        .clipShape(RoundedRectangle(cornerRadius: 12.0))
                                        .padding(8)
                                }
                            }
                        },
                        onDelete: {
                            // Delete chat from network
                            let chatID = chat.chatID
                            Task {
                                let authToken: String
                                do {
                                    authToken = try await AuthHelper.ensure()
                                } catch {
                                    // TODO: Handle errors
                                    print("Error ensuring authToken in ChatView... \(error)")
                                    return
                                }
                                
                                do {
                                    try await ChatHTTPSConnector.deleteChat(
                                        authToken: authToken,
                                        chatID: Int(chatID))
                                } catch {
                                    // TODO: Handle errors
                                    print("Error deleting chat in ChatView... \(error)")
                                    return
                                }
                            }
                            
                            // Delete chat from CoreData
                            viewContext.delete(chat)
                            
                            // Save context
                            do {
                                try viewContext.save()
                            } catch {
                                // TODO: Handle errors
                                print("Error saving context when deleting chat in ChatView... \(error)")
                            }
                        },
                        onCopy: {
                            // Copy TODO: Add footer and stuff if not premium
                            PasteboardHelper.copy(chat.text ?? "")
                        })
                    .transition(sender == .ai ? .opacity : .moveUp)
                    .rotationEffect(.degrees(180))
                    .padding(.bottom, 8)
                    .padding([.leading, .trailing])
                }
            }
        }
    }
    
    var gptSelector: some View {
        ZStack {
            GPTModelSelectionButton(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Show GPT model selection view
                withAnimation {
                    isShowingGPTModelSelectionView = true
                }
            })
        }
    }
    
    var entry: some View {
        VStack {
            //            Spacer()
            
            VStack(spacing: 12.0) {
                // Remaining Promo Button
                if !premiumUpdater.isPremium, let remaining = remainingUpdater.remaining {
                    KeyboardDismissingButton(action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Show Ultra View
                        isShowingUltraView = true
                    }) {
                        HStack {
                            Text("You have \(remaining) chats remaining today...")
                                .font(.custom(Constants.FontName.body, size: 12.0))
                            
                            Spacer()
                            
                            Text("Upgrade Now!")
                                .font(.custom(Constants.FontName.black, size: 12.0))
                        }
                    }
                    .padding([.top, .bottom], 4)
                    .padding([.leading, .trailing])
                    .foregroundStyle(Colors.elementTextColor)
                    .background(Colors.elementBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    
                }
                
                HStack(alignment: .bottom) {
                    EntryView(conversation: $conversation)
                        .onChange(of: chatGenerator.isLoading, perform: { value in
                            // Set face idle animation to thinking if isLoading
                            if value {
                                faceAnimationUpdater.setFaceIdleAnimationToThinking()
                            }
                        })
                        .onChange(of: chatGenerator.isGenerating, perform: { value in
                            // Set face idle animation to writing if isGenerating
                            if value {
                                faceAnimationUpdater.setFaceIdleAnimationToWriting()
                            }
                        })
                }
                
                // Free Trial Promo Button
                if !premiumUpdater.isPremium {
                    KeyboardDismissingButton(action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Show Ultra View
                        isShowingUltraView = true
                    }) {
                        ZStack {
                            HStack {
                                Spacer()
                                
                                Text(Image(systemName: "chevron.right"))
                                    .font(.custom(Constants.FontName.body, size: 20.0))
                                    .foregroundStyle(Colors.elementBackgroundColor)
                                    .padding(.trailing, 8)
                            }
                            
                            HStack {
                                Spacer()
                                
                                VStack(spacing: -2.0) {
                                    if let introductaryOffer = productUpdater.weeklyProduct?.subscription?.introductoryOffer {
                                        Text("NEW - Send Images\(introductaryOffer.paymentMode == .freeTrial ? "!" : "")")
                                            .font(.custom(Constants.FontName.heavy, size: 20.0))
                                            .foregroundStyle(Colors.elementBackgroundColor)
                                        
                                        if introductaryOffer.paymentMode == .freeTrial {
                                            Text("Get 3 Days Free...")
                                                .font(.custom(Constants.FontName.lightOblique, size: 17.0))
                                                .foregroundStyle(Colors.elementBackgroundColor)
                                        } else {
                                            Text("Get access for just 99¢ today!")
                                                .font(.custom(Constants.FontName.lightOblique, size: 17.0))
                                                .foregroundStyle(Colors.elementBackgroundColor)
                                        }
                                    } else {
                                        Text("NEW - Send Pictures!")
                                            .font(.custom(Constants.FontName.heavy, size: 20.0))
                                            .foregroundStyle(Colors.elementBackgroundColor)
                                        
                                        Text("Tap to upgrade now...")
                                            .font(.custom(Constants.FontName.lightOblique, size: 17.0))
                                            .foregroundStyle(Colors.elementBackgroundColor)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(8.0)
                    .background(
                        ZStack {
                            let cornerRadius = 14.0
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Colors.elementTextColor)
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Colors.elementBackgroundColor, lineWidth: 2.0)
                        }
                    )
                }
            }
            //            .padding(.bottom, 32)
            .padding([.leading, .trailing])
            .background(
                VStack(spacing: 0.0) {
                    if !premiumUpdater.isPremium {
                        Spacer(minLength: 14.0)
                    }
                    
                    LinearGradient(colors: [Colors.background, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 50.0)
                    Colors.background
                }
            )
        }
    }
    
    // MARK: - Functions
    
    func showFirstConversationChats(to conversation: Conversation, in viewContext: NSManagedObjectContext) async throws {
        //        // Load and show first chats
        //        await withCheckedContinuation { continuation in
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
        //                continuation.resume()
        //            })
        //        }
        
        try await MainActor.run {
            try withAnimation(.none) {
                try ChatCDHelper.appendChat(sender: .ai, text: "Hi! I'm Prof. Write, your AI personal tutor...", to: conversation, in: viewContext)
            }
        }
        
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: {
                continuation.resume()
            })
        }
        
        try await MainActor.run {
            try ChatCDHelper.appendChat(sender: .ai, text: "Text or send a picture for help on difficult problems. Ask follow up questions to dive deep on a subject.", to: conversation, in: viewContext)
        }
        
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: {
                continuation.resume()
            })
        }
        
        try await MainActor.run {
            try ChatCDHelper.appendChat(sender: .ai, text: "Talk to me like a human. I remember what we talk about, so conversations flow naturally. Let's chat!", to: conversation, in: viewContext)
        }
    }
    
}

#Preview {
    let conversation = Conversation(context: CDClient.mainManagedObjectContext)
    
    let chat1 = Chat(context: CDClient.mainManagedObjectContext)
    chat1.text = "Test"
    chat1.sender = "user"
    chat1.conversation = conversation
    
    let chat2 = Chat(context: CDClient.mainManagedObjectContext)
    chat2.text = "Test AI"
    chat2.sender = "ai"
    chat2.conversation = conversation
    
    let chat3 = Chat(context: CDClient.mainManagedObjectContext)
    chat3.text = "Test"
    chat3.sender = "user"
    chat3.conversation = conversation
    
    let chat4 = Chat(context: CDClient.mainManagedObjectContext)
    chat4.text = "Test AI"
    chat4.sender = "ai"
    chat4.conversation = conversation
    
    let chat5 = Chat(context: CDClient.mainManagedObjectContext)
    chat5.imageData = UIImage(named: "AppIcon")?.pngData()
    chat5.sender = "user"
    chat5.conversation = conversation
    
    try? CDClient.mainManagedObjectContext.save()
    
    return VStack {ChatView(
        conversation: conversation,
        isShowingGPTModelSelectionView: .constant(false),
        transitionToNewConversation: .constant(false),
        shouldShowFirstConversationChats: false
    )
        //        GADBannerViewRepresentable(bannerID: "ca-app-pub-3940256099942544/2934735716", isLoaded: .constant(true))
        //            .frame(width: 320, height: 50)
    }
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
    .environmentObject(RemainingUpdater())
    .environmentObject(FaceAnimationUpdater())
}
