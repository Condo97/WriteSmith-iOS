//
//  EntryView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import SwiftUI

struct EntryView: View, KeyboardReadable {
    
    @Binding var conversation: Conversation
    let initialHeight: CGFloat = 32.0
    let maxHeight: CGFloat
    
    @Environment(\.requestReview) private var requestReview
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var chatGenerator: ConversationChatGenerator // TODO: Use @Environment with an optional, or maybe something else for this
    @EnvironmentObject private var premiumUpdater: PremiumUpdater // TODO: Use @Environment with an optional
    @EnvironmentObject private var remainingUpdater: RemainingUpdater // TODO: Use @Environment with an optional
    @EnvironmentObject private var faceAnimationUpdater: FaceAnimationUpdater // TODO: Use @Environment with an optional
    
    @State private var alertShowingUpgradeForFasterChats: Bool = false
    
    @State private var cameraViewCropFrame: CGRect?
    @State private var cameraViewInitialImage: UIImage?
    
    @State private var isKeyboardShowing: Bool = false
    
    @State private var isShowingCameraView: Bool = false
    @State private var isShowingInterstitial: Bool = false
    @State private var isShowingUltraView: Bool = false
    
    @State private var isDisplayingPromoSendImagesView: Bool = false
    
    @State private var text: String = ""
    @State private var image: UIImage?
    @State private var imageURL: String?
    
    @State private var uncroppedImage: UIImage?
    @State private var cropFrame: CGRect?
    
//    private let initialHeight: CGFloat = 32.0
    var buttonDisabled: Bool {
        (text.isEmpty && image == nil && (imageURL == nil || imageURL!.isEmpty)) || chatGenerator.isLoading
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            CameraButtonView(
                initialHeight: initialHeight,
                action: {
                    // Do light haptic
                    HapticHelper.doLightHaptic()
                    
                    // Set camera view crop frame and initial image to nil
                    cameraViewCropFrame = nil
                    cameraViewInitialImage = nil
                    
                    // Is showing Camera View
                    isShowingCameraView = true
                    
                    // Print text and isLoading for debugging
                    print(text.isEmpty)
                    print(chatGenerator.isLoading)
                })
            
            VStack(alignment: .leading) {
                if image != nil {
                    entryImage
                    
                    Divider()
                        .background(Colors.elementTextColor)
                }
                
                HStack(alignment: .bottom) {
                    entryTextField
                    
                    submitButton
                }
            }
            .onChange(of: buttonDisabled, perform: { value in
                print("REE")
            })
            .padding()
            .fixedSize(horizontal: false, vertical: true)
            .background(Colors.elementBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        }
        .background(
            InterstitialView(interstitialID: Keys.Ads.Interstitial.chatView, disabled: $premiumUpdater.isPremium, isPresented: $isShowingInterstitial))
        .fullScreenCover(isPresented: $isShowingCameraView, content: {
            CameraViewControllerRepresentable(
                isShowing: $isShowingCameraView,
                withCropFrame: cropFrame,
                withImage: cameraViewInitialImage,
                onAttach: { image, cropFrame, originalImage in
                    self.image = image
                    self.cropFrame = cropFrame
                    self.uncroppedImage = originalImage
                },
                onScan: { scanText in
                    text += text.isEmpty ? scanText : " " + scanText
            })
            .ignoresSafeArea()
        })
        .clearFullScreenCover(isPresented: $isDisplayingPromoSendImagesView, content: {
            PromoSendImagesView(isShowing: $isDisplayingPromoSendImagesView, pressedScan: {
                // Dismiss
                isDisplayingPromoSendImagesView = false
                
                // Get tempImage from image TODO: Image URL stuff
                let tempImage = image
                
                // Set image and imageURL to nil
                withAnimation {
                    image = nil
                    imageURL = nil
                }
                
                // Set initial image and crop frame as necessary
                if let uncroppedImage = uncroppedImage {
                    // If uncroppedImage can be unwrapped, set cameraViewInitialImage to uncroppedImage and cameraViewCropFrame to cropFrame
                    cameraViewInitialImage = uncroppedImage
                    cameraViewCropFrame = cropFrame
                } else {
                    // If uncroppedImage is nil, then set cameraViewInitialImage to tempImage
                    cameraViewInitialImage = tempImage
                }
                
                // Show cameraView
                isShowingCameraView = true
            })
        })
        .alert("Upgrade for FREE", isPresented: $alertShowingUpgradeForFasterChats, actions: {
            Button("Cancel", role: nil, action: {
                
            })
            
            Button("Start Free Trial", role: .cancel, action: {
                isShowingUltraView = true
            })
        }) {
            Text("Please upgrade to send chats faster. Good news... you can get this and GPT-4 for FREE!")
        }
    }
    
    // MARK: - Local Views
    
    var entryImage: some View {
        ZStack {
            if let image = image {
                Button(action: {
                    // Set initial image and crop frame as necessary
                    if let uncroppedImage = uncroppedImage {
                        // If uncroppedImage can be unwrapped, set cameraViewInitialImage to uncroppedImage and cameraViewCropFrame to cropFrame
                        cameraViewInitialImage = uncroppedImage
                        cameraViewCropFrame = cropFrame
                    } else {
                        // If uncroppedImage is nil, then set cameraViewInitialImage to tempImage
                        cameraViewInitialImage = image
                    }
                    
                    // Show camera view
                    isShowingCameraView = true
                }) {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200.0)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        
                        HStack(spacing: 0.0) {
                            Spacer()
                            
                            VStack(spacing: 0.0) {
                                Button(action: {
                                    withAnimation(.spring) {
                                        self.image = nil
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.custom(Constants.FontName.medium, size: 14.0))
                                }
                                .foregroundStyle(Colors.elementBackgroundColor)
                                .padding(6)
                                .background(Circle()
                                    .fill(Colors.elementTextColor))
                                
                                Spacer()
                            }
                        }
                        .padding(4)
                    }
                }
            }
        }
    }
    
    var entryTextField: some View {
        TextField("", text: $text, axis: .vertical)
            .textFieldTickerTint(Colors.elementTextColor)
            .placeholder(when: text.isEmpty, placeholder: {
                Text("Tap to start chatting...")
            })
            .dismissOnReturn()
            .onReceive(keyboardPublisher, perform: { newIsKeyboardVisible in
                if newIsKeyboardVisible && !isKeyboardShowing {
                    HapticHelper.doLightHaptic()
                }
                
                isKeyboardShowing = newIsKeyboardVisible
            })
            .font(.custom(Constants.FontName.medium, size: 20.0))
            .foregroundStyle(Colors.elementTextColor)
            .frame(minHeight: initialHeight)
            .frame(maxHeight: maxHeight)
    }
    
    var submitButton: some View {
        VStack {
            KeyboardDismissingButton(action: {
                // Do haptic
                HapticHelper.doLightHaptic()
                
                // If user is not premium and an image is attached, show send images promo and return
                if !premiumUpdater.isPremium && (image != nil || imageURL != nil) {
                    isDisplayingPromoSendImagesView = true
                    return
                }
                
                // If chatGenerajtor is loading, return
                if chatGenerator.isLoading {
                    return
                }
                
                // if chatGenerator isGenerating and user is not premium, show upgrade alert and return
                if chatGenerator.isGenerating && !premiumUpdater.isPremium {
                    alertShowingUpgradeForFasterChats = true
                    return
                }
                
                // Assign tempText to text, tempImage to image, and tempImageURL to imageURL
                let tempText = text
                let tempImage = image
                let tempImageURL = imageURL
                
                // Clear text, image, and imageURL
                text = ""
                image = nil
                imageURL = nil
                
                // Start task to generate chat
                Task {
                    // Defer setting face idle animation to smile to ensure it is set after the task completes
                    defer {
                        faceAnimationUpdater.setFaceIdleAnimationToSmile()
                    }
                    
                    // Ensure authToken, otherwise return TODO: Handle errors
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle errors
                        print("Error ensureing AuthToken in ChatView... \(error)")
                        return
                    }
                    
                    do {
                        try await chatGenerator.generateChat(
                            input: tempText,
                            image: tempImage,
                            imageURL: tempImageURL,
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
                
                // Show ad if not premium or review if ad not shown lol this is a funny way of doing it so it doesn't escape the function when returning
                {
                    if !premiumUpdater.isPremium && showInterstitialAtFrequency() {
                        return
                    }
                    
                    showReviewAtFrequency()
                }()
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 28.0)
                    .foregroundStyle(Colors.elementTextColor)
            }
            .disabled(buttonDisabled)
            .opacity(buttonDisabled ? 0.4 : 1.0)
        }
        .frame(height: initialHeight)
    }
    
    // MARK: - Functions
    
    func showInterstitialAtFrequency() -> Bool {
        // Ensure not premium, otherwise return false
        guard !premiumUpdater.isPremium else {
            // TODO: Handle errors if necessary
            return false
        }
        
        // Set isShowingInterstitial to true if generated chats count is more than one and its modulo ad frequency is 0 and return true
        let chatsFetchRequest = Chat.fetchRequest()
        chatsFetchRequest.predicate = NSPredicate(format: "%K = %@ AND %K = %@", #keyPath(Chat.conversation), conversation, #keyPath(Chat.sender), Sender.ai.rawValue)
        
        do {
            let generatedChatCount = try viewContext.count(for: chatsFetchRequest)//chats.filter({$0.sender == Sender.ai.rawValue}).count
            if generatedChatCount > 0 && remainingUpdater.remaining ?? 0 > 0 && generatedChatCount % Constants.adFrequency == 0 {
                isShowingInterstitial = true
                
                return true
            }
        } catch {
            // TODO: Handle errors if necessary
            print("Error counting generated chats and therefore showing interstitial in EntryView... \(error)")
        }
        
        // Return false
        return false
    }
    
    func showReviewAtFrequency() -> Bool {
        // Show review if generated chat count is more than one and its modulo review frequency is 0 and return true
        let chatsFetchRequest = Chat.fetchRequest()
        chatsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation)
        
        do {
            let generatedChatCount = try viewContext.count(for: chatsFetchRequest)//chats.filter({$0.sender == Sender.ai.rawValue}).count
            if generatedChatCount > 0 && generatedChatCount % Constants.reviewFrequency == 0 {
                requestReview()
                
                return true
            }
        } catch {
            // TODO: Handle errors if necessary
            print("Error counting generated chats and therefore showing review in EntryView... \(error)")
        }
        
        // Return false
        return false
    }
    
//    func buttonsDisabled(_ disabled: Bool) -> EntryView {
//        var newView = self
//        newView._buttonDisabled = State(initialValue: disabled)
//        return newView
//    }
    
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    
    let conversation = Conversation(context: CDClient.mainManagedObjectContext)
    
    let chat1 = Chat(context: CDClient.mainManagedObjectContext)
    chat1.text = "Chat text"
    chat1.conversation = conversation
    
    let chat2 = Chat(context: CDClient.mainManagedObjectContext)
    chat2.text = "Another chat text"
    chat2.conversation = conversation
    
    try? CDClient.mainManagedObjectContext.save()
    
    return EntryView(
        conversation: .constant(conversation),
        maxHeight: 400.0)
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        .environmentObject(ConversationChatGenerator())
        .environmentObject(PremiumUpdater())
        .environmentObject(RemainingUpdater())
        .environmentObject(FaceAnimationUpdater())
}
