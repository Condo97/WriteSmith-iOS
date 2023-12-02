//
//  ChatView.swift
//  WriteSmith_WatchApp_SelfContained Watch App
//
//  Created by Alex Coundouriotis on 11/4/23.
//

import SwiftUI

struct ChatView: View {
    
    @State private var conversation: Conversation
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest<Chat> private var chats: FetchedResults<Chat>
    
    @StateObject var chatGenerator = ConversationChatGenerator()
    
    @State private var currentlyDraggedChat: Chat?
    
    @State private var isDisplayingLoadingChatBubble: Bool = false
    
    @State private var entryText: String = ""
    
//    @State private var inputFieldDragTranslation: CGFloat = 0.0
    
    init(conversation: Conversation) {
        self._chats = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: false)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation.objectID),
            animation: .default)
        
        self._conversation = State(initialValue: conversation)
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(spacing: 4.0) {
                    if !premiumUpdater.isPremium {
                        remainingDisplay
                            .rotationEffect(.degrees(180))
                    }
                    
                    inputField
                        .rotationEffect(.degrees(180))
                    
                    //                ScrollView(.vertical) {
                    if isDisplayingLoadingChatBubble {
                        loadingChatBubble
                    }
                    
                    //                    VStack(spacing: 4.0) {
                    chatList
                    //                    }
                    //                }
                    //                .rotationEffect(.degrees(180))
                    
                    Spacer(minLength: 60.0)
                    
                }
            }
            .rotationEffect(.degrees(180))
            .ignoresSafeArea()
        }
        .onAppear {
            if chats.count == 0 {
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
    }
    
    var loadingChatBubble: some View {
        ChatBubbleView(
            sender: .ai,
            isDragged: .constant(false),
            content: {
                PulsatingDotsView(count: 4, size: 12.0)
                    .foregroundStyle(Colors.aiChatTextColor)
                    .padding(.leading, 5)
                    .padding(.trailing, 9)
            })
        .rotationEffect(.degrees(180))
        .padding(.bottom, 8)
        .padding([.leading, .trailing])
        //                                    .animation(.easeInOut(duration: 5.0), value: chatGenerator.isLoading)
        .transition(.move(edge: .bottom))
    }
    
    var chatList: some View {
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
                                    .font(.custom(sender == .user ? Constants.FontName.heavy : Constants.FontName.body, size: 10.0))
                                    .foregroundStyle(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                                //                        Spacer()
                            }
                            .padding([.top, .bottom], 12)
                            .padding([.leading, .trailing], 12)
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
                    .rotationEffect(.degrees(180))
                }
            }
        }
    }
    
    var inputField: some View {
        VStack(spacing: 0.0) {
//            HStack {
            TextField("Tap to Chat...", text: $entryText)
                .listItemTint(.blue)
                .font(.custom(Constants.FontName.body, size: 12.0))
                .textFieldStyle(PlainTextFieldStyle())
            
            Button(action: {
                let tempEntryText = entryText
                entryText = ""
                
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
            }) {
                HStack {
                    Spacer()
                    Text("Send \(Image(systemName: "arrow.up"))")
                        .font(.custom(Constants.FontName.heavy, size: 14.0))
                    Spacer()
                }
                .padding()
                .foregroundStyle(Colors.elementTextColor)
                .background(Colors.buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                .padding()
                .padding(.trailing, 4)
            }
            .buttonStyle(.plain)
            
            
        }
//        }
    }
    
    var remainingDisplay: some View {
        VStack {
            if let remaining = remainingUpdater.remaining {
                Text("You have \(remaining) chats remaining today.")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.custom(Constants.FontName.body, size: 9.0))
                
                Text("Try Unlimited for FREE!")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.custom(Constants.FontName.blackOblique, size: 8.0))
            }
        }
        .foregroundStyle(Colors.textOnBackgroundColor)
        .padding(.top, -8)
    }
    
}

#Preview {
    
    let conversation = Conversation(context: CDClient.mainManagedObjectContext)
    
    conversation.conversationID = Constants.defaultConversationID
    conversation.behavior = nil
    
    
    let chat = Chat(context: CDClient.mainManagedObjectContext)
    
    chat.text = "The chat"
    chat.sender = Sender.ai.rawValue
    chat.conversation = conversation
    
    
    try? CDClient.mainManagedObjectContext.save()
    
    
    return ChatView(conversation: conversation)
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        .environmentObject(RemainingUpdater())
        .environmentObject(PremiumUpdater())
    
}
