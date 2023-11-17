//
//  ConversationRow.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/12/23.
//

import Foundation
import SwiftUI

struct ConversationRow: View {
    
    @State var conversation: Conversation
    @State var action: ()->Void
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var formattedLatestChatDate: String? {
        guard let latestChatDate = conversation.latestChatDate else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        return dateFormatter.string(from: latestChatDate)
    }
    
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    // Conversation Title
                    Text(conversation.latestChatText ?? "No Chat...")
                        .font(.custom(conversation.latestChatText == nil ? Constants.FontName.bodyOblique : Constants.FontName.body, size: 17.0))
                        .lineLimit(1)
                    
                    // Conversation Formatted Date
                    Text(formattedLatestChatDate ?? "Unknown")
                        .font(.custom(Constants.FontName.heavy, size: 12.0))
                        .opacity(0.4)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let conversationToResume = try? ConversationResumingManager.getConversation(in: viewContext), conversationToResume == conversation {
                    // Conversation to resume image
                    Text(Image(systemName: "rectangle.and.pencil.and.ellipsis"))
                        .font(.custom(Constants.FontName.body, size: 20.0))
                        .opacity(0.4)
                }
                
                Image(systemName: "chevron.right")
                    .font(.custom(Constants.FontName.body, size: 20.0))
            }
        }
        .foregroundStyle(Colors.text)
        .padding(4)
        .listRowBackground(Colors.foreground)
    }
    
}
