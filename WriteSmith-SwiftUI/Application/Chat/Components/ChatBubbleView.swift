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
                            
                            //                        Spacer()
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    case .user:
                        HStack(spacing: 0.0) {
                            //                        Spacer()
                            
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
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(Colors.textOnBackgroundColor)
                        .opacity(0.4)
                    
                    Button(action: {
                        onDelete?()
                    }) {
                        Text("Delete")
                            .font(.custom(Constants.FontName.black, size: 17.0))
                    }
                    .foregroundStyle(Color(uiColor: .systemRed))
                    .padding([.top, .bottom], 8)
                    .padding([.leading, .trailing], 16)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 24.0))
                }
                .frame(minHeight: 0.0)
            }))
//            .offset(x: dragOffset)
//            .scaleEffect(1 - pow(Double(dragOffset) / 40, 2) / 100)
//            .opacity(1 - pow(Double(dragOffset) / 40, 2) / 100)
        }
//        .contentShape(Rectangle())
//        .onTapGesture {
//            if dragOffset != .zero {
//                withAnimation {
//                    dragOffset = .zero
//                }
//            }
//        }
//        .gesture(
//            DragGesture()
//                .onChanged { gesture in
//                    // Ensure canDrag, otherwise return
//                    guard canDrag else {
//                        return
//                    }
//                    
//                    // Ensure gesture translation width is less than or equal to 0, otherwise return so that rows can only be swiped left
//                    guard gesture.translation.width <= 0 else {
//                        return
//                    }
//                    
//                    // Set drag offset to gesture translation width
//                    dragOffset = gesture.translation.width
//                    
////                    if dragOffset <= -maxDragOffset {
////                        // If dragOffset is less than or equal to the left max drag offset, do light haptic
////                        HapticHelper.doLightHaptic()
////                    }
//                }
//                .onEnded { value in
//                    // Set the dragOffset to zero or left max drag offset depending on where the user released the row
//                    withAnimation {
//                        if dragOffset <= -maxDragOffset * 0.4 {
//                            dragOffset = -maxDragOffset
//                        } else {
//                            dragOffset = .zero
//                        }
//                    }
//                })
//        .onChange(of: dragOffset) { dragOffset in
//            if dragOffset == 0 {
//                isDragged = false
//            } else {
//                isDragged = true
//            }
//        }
//        .onChange(of: isDragged) { isDragged in
//            withAnimation {
//                dragOffset = isDragged ? -maxDragOffset : .zero
//            }
//        }
        
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

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    
    let chat = Chat(context: CDClient.mainManagedObjectContext)
    chat.text = "asdfadsf"
    chat.date = Date()
    
    try? CDClient.mainManagedObjectContext.save()
    
    return ChatBubbleView(
        sender: .ai,
        isDragged: .constant(false),
        content: {
            Text("Test")
    })
    .background(Color(uiColor: .gray))
}
