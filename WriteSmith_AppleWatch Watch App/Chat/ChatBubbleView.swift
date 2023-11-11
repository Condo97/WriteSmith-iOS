//
//  ChatBubbleView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import SwiftUI

struct ChatBubbleView<Content>: View where Content: View {
    
    @State var sender: Sender
    @Binding var isDragged: Bool
    var content: () -> Content
    var onDelete: (() -> Void)? = nil
    
    
    private let aiChatSenderImage: Image = Image(Constants.ImageName.aiChatImage)
    private let userChatSenderImage: Image = Image(systemName: "pencil")
    
    private let senderImageSize: CGFloat = 24.0
    
    private var currentChatSenderImage: Image {
        switch sender {
        case .ai:
            aiChatSenderImage
        case .user:
            userChatSenderImage
        case nil:
            // TODO: Handle this
            userChatSenderImage
        }
    }
    
    
    var body: some View {
        ZStack {
            HStack {
                if sender == .user {
                    Spacer(minLength: 0.0)
                }
                
                ZStack {
                    switch sender {
                    case .ai:
                        HStack(spacing: 0.0) {
                            senderImage
                            
                            bubble
                            
                            Spacer(minLength: 0.0)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    case .user:
                        HStack(spacing: 0.0) {
                            Spacer(minLength: 0.0)
                            
                            bubble
                            
                            senderImage
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                if sender == .ai {
                    Spacer(minLength: 0.0)
                }
                
            }
            .modifier(SwipeAction(isDragged: $isDragged, behind: {
                HStack(spacing: 16.0) {
                    Spacer(minLength: 0.0)
                    
                    Text("Cancel")
                        .font(.custom(Constants.FontName.body, size: 12.0))
                        .foregroundStyle(Colors.textOnBackgroundColor)
                        .opacity(0.4)
                    
                    Button(action: {
                        onDelete?()
                    }) {
                        Text("Delete")
                            .font(.custom(Constants.FontName.black, size: 12.0))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                    .padding([.top, .bottom], 4)
                    .padding([.leading, .trailing], 8)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 24.0))
                }
                .frame(minHeight: 0.0)
            }))
        }
        
    }
    
    var senderImage: some View {
        ZStack {
            VStack {
                Spacer()
                
                currentChatSenderImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(sender == .user ? 8 : 5)
                    .foregroundStyle(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                    .background(sender == .user ? Colors.userChatBubbleColor : Colors.aiChatBubbleColor)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    .frame(height: senderImageSize)
            }
        }
    }
    
    var bubble: some View {
        ZStack {
            ZStack {
                content()
                    .padding(sender == .user ? .trailing : .leading, 8.0)
            }
            .frame(minWidth: 40.0)
            .background(
                BubbleImageMaker.makeBubbleImage(userSent: sender == .user)
                    .foregroundStyle(sender == .user ? Colors.userChatBubbleColor : Colors.aiChatBubbleColor)
            )
        }
    }
    
}

@available(watchOS 10.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    
    let chat = Chat(context: CDClient.mainManagedObjectContext)
    chat.text = "asdfadsf"
    chat.date = Date()
    
    try? CDClient.mainManagedObjectContext.save()
    
    return ChatBubbleView(
        sender: .ai,
        isDragged: .constant(false),
        content: {
            HStack {
                Text("Hi")
                    .font(.custom(Constants.FontName.body, size: 10.0))
                    .foregroundStyle(Colors.aiChatTextColor)
//                                        Spacer()
            }
            .padding([.top, .bottom], 12)
            .padding([.leading, .trailing], 12)
    })
    .background(Color(uiColor: .gray))
}
