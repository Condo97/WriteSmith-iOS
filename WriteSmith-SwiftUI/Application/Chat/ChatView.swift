//
//  ChatView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import CoreData
import SwiftUI

struct ChatView: View, KeyboardReadable {
    
//    @ObservedObject var conversation: Conversation
    @ObservedObject private var premiumUpdater: PremiumUpdater
    @ObservedObject private var remainingUpdater: RemainingUpdater
    @Binding private var faceAnimationController: FaceAnimationRepresentable?
    @Binding private var isShowingGPTModelSelectionView: Bool
    @Binding private var transitionToNewConversation: Bool
    @State private var shouldShowFirstConversationChats: Bool
    
    
    private let chatsBottomPadding: CGFloat = 140.0
    
//    @StateObject private var gadInterstitialCoodrinator: GADInterstitialCoordinator = GADInterstitialCoordinator(interstitialID: Keys.Ads.Interstitial.chatView)
//    @State private var gadInterstitialViewControllerRepresentable: GADBlankAdContainerViewController = GADBlankAdContainerViewController()
    
    @Environment(\.requestReview) private var requestReview
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest<Chat> private var chats: FetchedResults<Chat>
    
    @StateObject private var chatGenerator: ConversationChatGenerator = ConversationChatGenerator()
    
    @State private var entryText: String = ""
    
    @State private var isDisplayingLoadingChatBubble: Bool = false
    
    @State private var alertShowingUpgradeForFasterChats: Bool = false
    @State private var alertShowingUpgradeForUnlimitedChats: Bool = false
    
    @State private var isShowingCameraView: Bool = false
    @State private var isShowingInterstitial: Bool = false
    @State private var isShowingUltraView: Bool = false
    
    @State private var isKeyboardVisible: Bool = false
    
    @State private var conversation: Conversation
    
    @State private var currentlyDraggedChat: Chat?
    
    
    init(conversation: Conversation, premiumUpdater: ObservedObject<PremiumUpdater>, remainingUpdater: ObservedObject<RemainingUpdater>, faceAnimationController: Binding<FaceAnimationRepresentable?>, isShowingGPTModelSelectionView: Binding<Bool>, transitionToNewConversation: Binding<Bool>, shouldShowFirstConversationChats: Bool) {
        self._chats = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: false)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation.objectID),
            animation: .default)
        
        self._conversation = State(initialValue: conversation)
        self._premiumUpdater = premiumUpdater
        self._remainingUpdater = remainingUpdater
        self._faceAnimationController = faceAnimationController
        self._isShowingGPTModelSelectionView = isShowingGPTModelSelectionView
        self._transitionToNewConversation = transitionToNewConversation
        self._shouldShowFirstConversationChats = State(initialValue: shouldShowFirstConversationChats)
        
        if !shouldShowFirstConversationChats && conversation.chats?.count == 0 {
            // If there are no chats, add the initial one
            do {
                // TODO: This uses CDClient mainManagedObjectContext instead of viewContext, is there a better way to do this?
                try ChatCDHelper.appendChat(
                    sender: .ai,
                    text: FirstChats.getRandomFirstChat(),
                    to: conversation,
                    in: CDClient.mainManagedObjectContext)
            } catch {
                // TODO: Handle errors
                print("Error appending chat in ChatView... \(error)")
            }
        }
        
        // Set ConversationResumingManager conversation TODO: This uses CDClient mainManagedObjectContext
        do {
            try ConversationResumingManager.setConversation(conversation, in: CDClient.mainManagedObjectContext)
        } catch {
            // TODO: Handle errors
            print("Error obtaining permanent ID for conversation in ConversationView... \(error)")
        }
        
//        // If there are no chats, add the initial one TODO: This uses CDClient mainManagedObjectContext
//        if conversation.chats?.count == 0 {
//            do {
//                try ChatCDHelper.appendChat(
//                    sender: .ai,
//                    text: FirstChatGenerator.getRandomFirstChat(),
//                    to: conversation,
//                    in: CDClient.mainManagedObjectContext)
//            } catch {
//                // TODO: Handle errors
//                print("Error appending chat in ChatView... \(error)")
//            }
//        }
    }
    
//    var testingthing: some View {
//        GADBannerViewRepresentable(bannerID: Keys.Ads.Banner.chatView, isLoaded: $isBannerViewLoaded)
//            .frame(height: 50)
//    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if !premiumUpdater.isPremium {
                    BannerView(bannerID: Keys.Ads.Banner.chatView)
                }
                
//                GeometryReader { geo in
                    ZStack {
                        // List
                        VStack {
                            ScrollView(.vertical) {
//                            List {
                                Spacer(minLength: premiumUpdater.isPremium ? 100.0 : 180.0)
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
//                            .scrollContentBackground(.hidden)
//                            .listRowInsets(nil)
                            .scrollIndicators(.never)
                            .rotationEffect(.degrees(180))
                        }
//                        .ignoresSafeArea()
                        
                        // GPT selector
                        gptSelector
                        
//                        // Entry
//                        ScrollView {
                            VStack {
                                Spacer()
                                
                                entry
                                
//                                Color.clear
//                                    .frame(height: isKeyboardVisible ? 0.0 : 32.0)
//                                    .ignoresSafeArea(.keyboard)
                            }
//                            .frame(minHeight: geo.size.height)
//                        }
//                        .allowsHitTesting(false)
//                        .scrollDisabled(true)
                        
                    }
                    .padding(.bottom, isKeyboardVisible ? 8.0 : 48.0)
//                    .safeAreaInset(edge: .bottom, content: {
//                        entry
//                    })
//                    .ignoresSafeArea()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(.visible, for: .navigationBar)
                    .toolbar {
                        LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
                        
                        AddChatToolbarItem(elementColor: .constant(Colors.elementTextColor), trailingPadding: premiumUpdater.isPremium ? 0.0 : -12.0, action: {
                            transitionToNewConversation = true
                        })
                        
                        if !premiumUpdater.isPremium {
                            UltraToolbarItem(
                                premiumUpdater: premiumUpdater,
                                remainingUpdater: remainingUpdater)
                        }
                    }
                    .toolbarBackground(Colors.topBarBackgroundColor, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
//                }
                
            }
            .background(Colors.background)
        }
        .background(
            InterstitialView(interstitialID: Keys.Ads.Interstitial.chatView, disabled: $premiumUpdater.isPremium, isPresented: $isShowingInterstitial))
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
        .ultraViewPopover(
            isPresented: $isShowingUltraView,
            premiumUpdater: premiumUpdater)
//        .keyboardDismissingTextFieldToolbar("Done", color: Colors.buttonBackground)
        .scrollDismissesKeyboard(.immediately)
        .fullScreenCover(isPresented: $isShowingCameraView, content: {
            CameraViewControllerRepresentable(onScan: { scanText in
                // Start task to generate chat and update remaining TODO: Should this just directly add to entryText?
                Task {
                    // Ensure authToken, otherwise return TODO: Handle errors
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle errors
                        print("Error ensureing AuthToken in ChatView... \(error)")
                        return
                    }
                    
                    // If not premium and no chats remaining, show alert
                    if !premiumUpdater.isPremium && remainingUpdater.remaining ?? 0 <= 0 {
                        alertShowingUpgradeForUnlimitedChats = true
                    }
                    
                    // Generate chat
                    do {
                        try await chatGenerator.generateChat(
                            input: scanText,
                            conversation: conversation,
                            authToken: authToken,
                            isPremium: premiumUpdater.isPremium,
                            remainingUpdater: remainingUpdater,
                            in: viewContext)
                    } catch {
                        // TODO: Handle errors
                        print("Error generating chat in ChatView... \(error)")
                    }
                }
            })
            .ignoresSafeArea()
        })
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
        .alert("Upgrade for FREE", isPresented: $alertShowingUpgradeForFasterChats, actions: {
            Button("Cancel", role: nil, action: {
                
            })
            
            Button("Start Free Trial", role: .cancel, action: {
                isShowingUltraView = true
            })
        }) {
            Text("Please upgrade to send chats faster. Good news... you can get this and GPT-4 for FREE!")
        }
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
    
    var loadingChatBubble: some View {
        ChatBubbleView(
            sender: .ai,
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
//        List {
            ForEach(chats) { chat in
                if let chatSender = chat.sender, let sender = Sender(rawValue: chatSender), let text = chat.text {
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
                            isDragged: isDragged,
                            content: {
                                HStack {
                                    Text(text)
                                        .font(.custom(sender == .user ? Constants.FontName.heavy : Constants.FontName.body, size: 14.0))
                                        .foregroundStyle(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                                    //                        Spacer()
                                }
                                .padding([.top, .bottom], 14)
                                .padding([.leading, .trailing], 14)
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
                            })
                        .transition(sender == .ai ? .opacity : .moveUp)
                        .rotationEffect(.degrees(180))
                        .padding(.bottom, 8)
                        .padding([.leading, .trailing])
                    }
//                    .swipeActions(edge: .leading) {
//                        Button(action: {
//                            print("RHLJDSHFKJLHDJKFHD\n\n\n\n\n\n\n\\n\\nn\n\\n\n\n\n\nasdfasdf")
//                        }) {
//                            Text("Testing")
//                        }
//                    }
    //                .padding([.leading, .trailing])
//                    .onDra
                }
            }
    //        .swipeActions {
    //            Button("Swipe", action: {
    //                
    //            })
    //        }
//            .onDelete(perform: { indexSet in
//                // Delete all chats for indicies in indexSet TODO: Is this the right or best way to do this?
//                for index in indexSet {
//                    viewContext.delete(chats[index])
//                }
//                
//                // Save context
//                do {
//                    try viewContext.save()
//                } catch {
//                    // TODO: Handle errors
//                    print("Error saving context in ChatView... \(error)")
//                }
//        })
//        }
    }
    
    var gptSelector: some View {
        ZStack {
            GPTModelSelectionButton(action: {
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
                    let initialHeight = 32.0
                    
                    CameraButtonView(
                        initialHeight: initialHeight,
                        action: {
                            isShowingCameraView = true
                            
                            print(entryText.isEmpty)
                            print(chatGenerator.isLoading)
                        })
                    
                    EntryView(
                        text: $entryText,
                        initialHeight: initialHeight,
                        buttonDisabled: entryText.isEmpty || chatGenerator.isLoading,
                        onSubmit: {
                            // If chatGenerajtor is loading, return
                            if chatGenerator.isLoading {
                                return
                            }
                            
                            // if chatGenerator isGenerating and user is not premium, show upgrade alert and return
                            if chatGenerator.isGenerating && !premiumUpdater.isPremium {
                                alertShowingUpgradeForFasterChats = true
                                return
                            }
                            
                            // Assign tempEntryText to entryText
                            let tempEntryText = entryText
                            
                            // Clear entryText
                            entryText = ""
                            
                            // Start task to generate chat
                            Task {
                                // Defer setting face idle animation to smile to ensure it is set after the task completes
                                defer {
                                    setFaceIdleAnimationToSmile()
                                }
                                
                                // Ensure authToken, otherwise return TODO: Handle errors
                                let authToken: String
                                do {
                                    authToken = try await AuthHelper.ensure()
                                } catch {
                                    // TODO: Handle errors
                                    print("Error ensureing AuthToken in ChatView... \(error)")
                                    return
                                }
                                
                                do {
                                    try await chatGenerator.generateChat(
                                        input: tempEntryText,
                                        conversation: conversation,
                                        authToken: authToken,
                                        isPremium: premiumUpdater.isPremium,
                                        remainingUpdater: remainingUpdater,
                                        in: viewContext)
                                } catch {
                                    // TODO: Handle errors
                                    print("Error generating chat in ChatView... \(error)")
                                }
                            }
                            
                            // Show ad if not premium or review if ad not shown lol this is a funny way of doing it so it doesn't escape the function when returning
                            {
                                if !premiumUpdater.isPremium && showInterstitialAtFrequency() {
                                    return
                                }
                                
                                showReviewAtFrequency()
                            }()
                        })
                    .onChange(of: chatGenerator.isLoading, perform: { value in
                        // Set face idle animation to thinking if isLoading
                        if value {
                            setFaceIdleAnimationToThinking()
                        }
                    })
                    .onChange(of: chatGenerator.isGenerating, perform: { value in
                        // Set face idle animation to writing if isGenerating
                        if value {
                            setFaceIdleAnimationToWriting()
                        }
                    })
                    //                .buttonsDisabled(entryText.isEmpty || chatGenerator.isLoading)
                }
                
                // Free Trial Promo Button
                if !premiumUpdater.isPremium {
                    KeyboardDismissingButton(action: {
                        isShowingUltraView = true
                    }) {
                        HStack {
                            Spacer()
                            
                            Text("Get 3 Days Free...")
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                                .foregroundStyle(Colors.elementBackgroundColor)
                            
                            Spacer()
                        }
                    }
                    .padding(12)
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
    
    func showFirstConversationChats(to conversation: Conversation, in viewContext: NSManagedObjectContext) async throws {
//        // Load and show first chats
//        await withCheckedContinuation { continuation in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
//                continuation.resume()
//            })
//        }
        
        try withAnimation(.none) {
            try ChatCDHelper.appendChat(sender: .ai, text: "Hi! I'm Prof. Write, your AI writing companion...", to: conversation, in: viewContext)
        }
        
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: {
                continuation.resume()
            })
        }
        
        try ChatCDHelper.appendChat(sender: .ai, text: "Ask me to write lyrics, poems, essays and more. Talk to me like a human and ask me anything you'd ask your professor!", to: conversation, in: viewContext)
        
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: {
                continuation.resume()
            })
        }
        
        try ChatCDHelper.appendChat(sender: .ai, text: "I do better with more detail. Don't say, \"Essay on Belgium,\" say \"200 word essay on Belgium's cultural advances in the past 20 years.\" Remember, I'm your Professor, so use what I write as inspiration and never plagiarize!", to: conversation, in: viewContext)
    }
    
    func showInterstitialAtFrequency() -> Bool {
        // Ensure not premium, otherwise return false
        guard !premiumUpdater.isPremium else {
            // TODO: Handle errors if necessary
            return false
        }
        
        // Set isShowingInterstitial to true if generated chats count is more than one and its modulo ad frequency is 0 and return true
        let generatedChatCount = chats.filter({$0.sender == Sender.ai.rawValue}).count
        if generatedChatCount > 0 && generatedChatCount % Constants.adFrequency == 0 {
            isShowingInterstitial = true
            
            return true
        }
        
        // Return false
        return false
    }
    
    func showReviewAtFrequency () -> Bool {
        // Show review if generated chat count is more than one and its modulo review frequency is 0 and return true
        let generatedChatCount = chats.filter({$0.sender == Sender.ai.rawValue}).count
        if generatedChatCount > 0 && generatedChatCount % Constants.reviewFrequency == 0 {
            requestReview()
            
            return true
        }
        
        // Return false
        return false
    }
    
    func setFaceIdleAnimationToSmile() {
        faceAnimationController?.setIdleAnimations(RandomFaceIdleAnimationSequence.smile)
    }
    
    func setFaceIdleAnimationToThinking() {
        faceAnimationController?.setIdleAnimations(RandomFaceIdleAnimationSequence.thinking)
    }
    
    func setFaceIdleAnimationToWriting() {
        faceAnimationController?.setIdleAnimations(RandomFaceIdleAnimationSequence.writing)
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
    
    try? CDClient.mainManagedObjectContext.save()
    
    return VStack {ChatView(
        conversation: conversation,
        premiumUpdater: ObservedObject(initialValue: PremiumUpdater()),
        remainingUpdater: ObservedObject(initialValue: RemainingUpdater()),
        faceAnimationController: .constant(nil),
        isShowingGPTModelSelectionView: .constant(false),
        transitionToNewConversation: .constant(false),
        shouldShowFirstConversationChats: false
    )
//        GADBannerViewRepresentable(bannerID: "ca-app-pub-3940256099942544/2934735716", isLoaded: .constant(true))
//            .frame(width: 320, height: 50)
    }
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
}
