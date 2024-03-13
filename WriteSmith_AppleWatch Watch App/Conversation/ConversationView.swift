//
//  ConversationView.swift
//  WriteSmith_WatchApp_SelfContained Watch App
//
//  Created by Alex Coundouriotis on 11/4/23.
//

import SwiftUI

struct ConversationView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest<Conversation>(
        sortDescriptors: [NSSortDescriptor(keyPath: \Conversation.latestChatDate, ascending: false)],
        animation: .default)
    private var conversations
    
    @State private var presentingConversation: Conversation?
    private var isPresentingConversation: Binding<Bool> {
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
            ScrollView(.vertical) {
                newConversation
                
                if conversations.count == 0 {
                    introRow
                }
                
                conversationList
            }
            .navigationDestination(isPresented: isPresentingConversation, destination: {
                if let presentingConversation = presentingConversation {
                    ChatView(conversation: presentingConversation)
                }
            })
        }
    }
    
    var newConversation: some View {
        Button(action: {
            // TODO: probably can be converted to ConversationCDHelper.create(in:) or something?
            let conversation = Conversation(context: viewContext)
            conversation.conversationID = Constants.defaultConversationID
            conversation.behavior = nil
            
            // TODO: This is for testing, need to remove!
            conversation.latestChatDate = Date()
            
            DispatchQueue.main.async {
                do {
                    try viewContext.save()
                    
                    presentingConversation = conversation
                } catch {
                    // TODO: Handle errors
                    print("Error saving context in ConversationView... \(error)")
                }
            }
        }) {
            HStack {
                Spacer()
                
                Text("\(Image(systemName: "plus")) New Chat")
                    .font(.custom(Constants.FontName.black, size: 17.0))
                    .foregroundStyle(Colors.elementTextColor)
                
                Spacer()
            }
            .padding()
            .background(Colors.buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
        }
        .buttonStyle(.plain)
        
    }
    
    var introRow: some View {
        VStack {
            Text("Create a chat and send your first message.")
                .font(.custom(Constants.FontName.body, size: 14.0))
                .multilineTextAlignment(.center)
                .opacity(0.6)
        }
        .padding()
    }
    
    var conversationList: some View {
        ForEach(conversations) { conversation in
            ConversationRowView(
                conversation: conversation,
                action: {
                    presentingConversation = conversation
                })
        }
    }
    
}

#Preview {
    ConversationView()
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        .environmentObject(RemainingUpdater())
        .environmentObject(PremiumUpdater())
}
