//
//  ConversationRowView.swift
//  WriteSmith_WatchApp_SelfContained Watch App
//
//  Created by Alex Coundouriotis on 11/4/23.
//

import SwiftUI

struct ConversationRowView: View {
    
    @State var conversation: Conversation
    var action: ()->Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private let defaultLatestChatText = "No Chats..."
    
    private let defaultDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter
    }()
    
    
    var body: some View {
        ZStack {
            if let latestChatDate = conversation.latestChatDate {
                Button(action: {
                    action()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 0.0) {
                            Text(conversation.latestChatText ?? defaultLatestChatText)
                                .font(.custom(conversation.latestChatText == nil ? Constants.FontName.body : Constants.FontName.body, size: 14.0))
                                .lineLimit(2)
                            
                            Text(defaultDateFormatter.string(from: latestChatDate))
                                .font(.custom(Constants.FontName.heavy, size: 10.0))
                                .opacity(0.4)
                        }
                        
                        Spacer(minLength: 0.0)
                        
                        Text(Image(systemName: "chevron.right"))
                    }
                    .padding([.leading, .trailing])
                    .padding(2)
                    .background(Colors.background.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
}

#Preview {
//    ConversationRowView()
    ConversationView()
        .environmentObject(RemainingUpdater())
        .environmentObject(PremiumUpdater())
}
