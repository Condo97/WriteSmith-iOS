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
    var onDelete: (() -> Void)?
    var onCopy: (() -> Void)?
    
    
    @State private var isBounced: Bool = false
    @State private var isShowingCopyText: Bool = false
    
    private let aiChatSenderImage: Image = Image(Constants.ImageName.aiChatImage)
    private let userChatSenderImage: Image = Image(systemName: "pencil")
    
    private let copiedTextAnimationDuration: CGFloat = 0.2
    private let copiedTextAnimationDelay: CGFloat = 0.4
    
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
                            
//                        Spacer()
                        }
//                        .fixedSize(horizontal: false, vertical: true)
                    case .user:
                        HStack(spacing: 0.0) {
//                            Spacer()
                            
                            bubble
                            
                            senderImage
                        }
//                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                if sender == .ai {
                    Spacer(minLength: 0.0)
                }
                
            }
            .modifier(SwipeAction(isDragged: $isDragged, behind: {
                HStack(spacing: 16.0) {
                    Spacer(minLength: 0.0)
                    
                    Button(action: {
                        isDragged = false
                    }) {
                        Text("Cancel")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                    }
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
        .simultaneousGesture(TapGesture()
            .onEnded({
                // Ensure not isDragged, otherwise return
                guard !isDragged else {
                    return
                }
                
                // Set isBounced to true to do bounce
                isBounced = true
                
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Do onCopy
                onCopy?()
                
                // Show "Copied" text
                Task {
                    do {
                        try await showCopiedText()
                    } catch {
                        // TODO: Handle errors
                        print("Error showing copied text in ChatBubbleView... \(error)")
                    }
                }
            })
        )
        .bounceableOnChange(bounce: $isBounced)
        
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
                    .frame(height: 32.0)
            }
        }
    }
    
    var bubble: some View {
        ZStack {
            ZStack {
                content()
                    .opacity(isShowingCopyText ? 0.0 : 1.0)
                
                if isShowingCopyText {
                    Text("Copied")
                        .font(.custom(Constants.FontName.black, size: 20.0))
                        .foregroundStyle(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                }
            }
            .padding(sender == .user ? .trailing : .leading, 8.0)
            .frame(minWidth: 40.0)
            .background(
                BubbleImageMaker.makeBubbleImage(userSent: sender == .user)
                    .foregroundStyle(sender == .user ? Colors.userChatBubbleColor : Colors.aiChatBubbleColor)
            )
        }
    }
    
    func showCopiedText() async throws {
        // Ensure not isShowingCopyText, otherwise return
        guard !isShowingCopyText else {
            return
        }
        
        // Defer setting isShowingCopyText to false to ensure it is always executed on completion
        defer {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: copiedTextAnimationDuration)) {
                    isShowingCopyText = false
                }
            }
        }
        
        // Set isShowingCopyText to true
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: copiedTextAnimationDuration)) {
                isShowingCopyText = true
            }
        }
        
        // Wait for copiedTextAnimationDelay
        try await Task.sleep(nanoseconds: UInt64(copiedTextAnimationDelay * CGFloat(1_000_000_000)))
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
