//
//  ChatManagedReviewPrompt.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import Foundation
import SwiftUI

// Show every 10 times

struct ChatManagedReviewPrompt: View {
    
    @Binding var isPresented: Bool
    @State var chatCount: Int
    
    private static let showReviewPromptInitialDelay = 3 // The prompt will pop up when the chat count reaches this number, then every time described by chat count % frequency - this number
    private static let showReviewPromptFrequency = 10 // The amount of chats till the ReviewPrompt is shown, as described by chat count % this number - prompt initial delay
    
    
    @State private var isShowingReviewPrompt = false
    
    
    var body: some View {
        ReviewPrompt(isPresented: $isShowingReviewPrompt)
            .onChange(of: isPresented, perform: { value in
                if value {
                    // If changed to true, show the reviewPrompt depending on chatCount
                    if chatCount > 0 &&
                        chatCount % ChatManagedReviewPrompt.showReviewPromptFrequency - ChatManagedReviewPrompt.showReviewPromptInitialDelay == 0 {
                        // Show review prompt
                        isShowingReviewPrompt = true
                    } else {
                        // Set isPresented to false
                        DispatchQueue.main.async {
                            isPresented = false
                        }
                    }
                } else {
                    // If changed to false, dismiss the reviewPrompt
                    isShowingReviewPrompt = false
                }
            })
    }
    
}
