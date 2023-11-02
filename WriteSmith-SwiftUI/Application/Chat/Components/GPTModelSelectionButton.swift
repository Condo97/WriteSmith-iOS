//
//  GPTModelSelectionButton.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/28/23.
//

import SwiftUI

struct GPTModelSelectionButton: View {
    
    @State var action: () -> Void
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var animationPlayCount: Int = 0
    
    @State private var isGPTSelectorGifPlaying = true
    
    private let defaultAnimationDelay: CGFloat = 1.4
    
    private var model: GPTModels {
        GPTModelHelper.currentChatModel
    }
    
    
    var body: some View {
        VStack {
            KeyboardDismissingButton(action: {
                action()
            }) {
                ZStack {
                    HStack(spacing: 8.0) {
                        neatLittleGif
                        
                        switch model {
                        case .gpt3turbo:
                            gpt3TurboText
                        case .gpt4:
                            gpt4Text
                        }
                    }
                    .foregroundStyle(Colors.elementBackgroundColor)
                }
            }
            .padding([.leading, .trailing], 8)
            .padding([.top, .bottom], 4)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24.0)
                        .stroke(Colors.elementBackgroundColor, lineWidth: 4.0)
                    RoundedRectangle(cornerRadius: 24.0)
                        .fill(Colors.elementTextColor)
                }
                .shadow(color: Colors.background, radius: 14)
            )
            .padding(.top, 8)
            
            Spacer()
        }
        .onAppear {
            doAnimationRecursive()
        }
    }
    
    var neatLittleGif: some View {
        SwiftyGif(name: colorScheme == .dark ? Constants.ImageName.gptModelGifElementDark : Constants.ImageName.gptModelGifElementLight, loopCount: 1, playGif: $isGPTSelectorGifPlaying)
            .frame(width: 34, height: 34)
    }
    
    var gpt3TurboText: some View {
        HStack {
            Text("TURBO")
                .font(.custom(Constants.FontName.body, size: 17.0))
            +
            Text(" GPT-3")
                .font(.custom(Constants.FontName.black, size: 17.0))
        }
    }
    
    var gpt4Text: some View {
        HStack {
            Text("PRO")
                .font(.custom(Constants.FontName.black, size: 17.0))
            +
            Text(" GPT-4")
                .font(.custom(Constants.FontName.body, size: 17.0))
        }
    }
    
    private func doAnimationRecursive() {
        // Do animation
        DispatchQueue.main.async {
            isGPTSelectorGifPlaying.toggle()
        }
        
        // Add one to animatoinPlayCount
        animationPlayCount += 1
        
        // Set delayTimeInterval as the defaultAnimationDelay raised to animationPlayCount
        let delayTimeInterval = pow(defaultAnimationDelay, CGFloat(animationPlayCount))
        
        Timer.scheduledTimer(withTimeInterval: delayTimeInterval, repeats: false, block: { timer in
            doAnimationRecursive()
        })
    }
}

#Preview {
    GPTModelSelectionButton(action: {
        print("Action!")
    })
    .background(Colors.text)
}
