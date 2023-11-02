//
//  ChatBubbleView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import SwiftUI

struct ChatBubbleView<Content>: View where Content: View {
    
    @State var sender: Sender
    var content: () -> Content
    
    
    private let aiChatBubbleImage: Image = Image(Constants.ImageName.aiChatImage)
    private let userChatBubbleImage: Image = Image(systemName: "pencil")
    
    
    private var currentChatBubbleImage: Image {
        switch sender {
        case .ai:
            aiChatBubbleImage
        case .user:
            userChatBubbleImage
        case nil:
            // TODO: Handle this
            userChatBubbleImage
        }
    }
    
    
    var body: some View {
        ZStack {
            ZStack {
                switch sender {
                case .ai:
                    HStack(spacing: 0.0) {
                        senderImage
                        
                        bubble
                        
                        Spacer()
                    }
                    .fixedSize(horizontal: false, vertical: true)
                case .user:
                    HStack(spacing: 0.0) {
                        Spacer()
                        
                        bubble
                        
                        senderImage
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    var senderImage: some View {
        ZStack {
            VStack {
                Spacer()
                
                currentChatBubbleImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(sender == .user ? 8 : 5)
                    .foregroundStyle(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                    .background(sender == .user ? Colors.userChatBubbleColor : Colors.aiChatBubbleColor)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    .frame(height: 32.0)
            }
        }
    }
    
    var bubble: some View {
        ZStack {
            ZStack {
                content()
            }
            .frame(minWidth: 40.0)
            .background(
                BubbleImageMaker.makeBubbleImage(userSent: sender == .user)
                    .foregroundStyle(sender == .user ? Colors.userChatBubbleColor : Colors.aiChatBubbleColor)
            )
        }
    }
    
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    
    let chat = Chat(context: CDClient.mainManagedObjectContext)
    chat.text = "asdfadsf"
    chat.date = Date()
    
    try? CDClient.mainManagedObjectContext.save()
    
    return ChatBubbleView(sender: .ai, content: {
        Text("Test")
    })
    .background(Color(uiColor: .gray))
}
