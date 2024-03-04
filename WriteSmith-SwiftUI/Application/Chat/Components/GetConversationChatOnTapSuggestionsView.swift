////
////  GetConversationChatOnTapSuggestionsView.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 3/3/24.
////
//
//import Foundation
//import SwiftUI
//
//struct GetConversationChatOnTapSuggestionsView: View {
//    
//    @Binding var isActive: Bool
//    
//    @EnvironmentObject private var chatGenerator: ConversationChatGenerator
//    
//    
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    @State private var selected: String = ""
//    
//    var body: some View {
//        SuggestionsView(
//            isActive: $isActive,
//            selected: $selected)
//        .onChange(of: selected, perform: { value in
//            if !value.isEmpty {
//                // If value has text, that means something was selected, so generate chat, reset selected, and dismiss
//                
//                // TODO: This was all duplicated from EntryView.. make it better and more universal
//                // Do haptic
//                HapticHelper.doLightHaptic()
//                
//                // If chatGenerator is loading, return
//                if chatGenerator.isLoading {
//                    return
//                }
//                
//                // if chatGenerator isGenerating and user is not premium, show upgrade alert and return
//                if chatGenerator.isGenerating && !premiumUpdater.isPremium {
//                    alertShowingUpgradeForFasterChats = true
//                    return
//                }
//                
//                // Assign tempText to text, tempImage to image, and tempImageURL to imageURL
//                let tempText = text
//                let tempImage = image
//                let tempImageURL = imageURL
//                
//                // Clear text, image, and imageURL
//                text = ""
//                image = nil
//                imageURL = nil
//                
//                // Start task to generate chat
//                Task {
//                    // Defer setting face idle animation to smile to ensure it is set after the task completes
//                    defer {
//                        faceAnimationUpdater.setFaceIdleAnimationToSmile()
//                    }
//                    
//                    // Ensure authToken, otherwise return TODO: Handle errors
//                    let authToken: String
//                    do {
//                        authToken = try await AuthHelper.ensure()
//                    } catch {
//                        // TODO: Handle errors
//                        print("Error ensureing AuthToken in ChatView... \(error)")
//                        return
//                    }
//                    
//                    do {
//                        try await chatGenerator.generateChat(
//                            input: tempText,
//                            image: tempImage,
//                            imageURL: tempImageURL,
//                            conversation: conversation,
//                            authToken: authToken,
//                            isPremium: premiumUpdater.isPremium,
//                            remainingUpdater: remainingUpdater,
//                            in: viewContext)
//                    } catch {
//                        // TODO: Handle errors
//                        print("Error generating chat in ChatView... \(error)")
//                    }
//                }
//                
//                if premiumUpdater.isPremium || !showInterstitialAtFrequency() {
//                    isShowingReviewModel = true
//                }
//            }
//        })
//    }
//    
//}
//
//#Preview {
//    
//    GetConversationChatOnTapSuggestionsView(isActive: .constant(true))
//    
//}
