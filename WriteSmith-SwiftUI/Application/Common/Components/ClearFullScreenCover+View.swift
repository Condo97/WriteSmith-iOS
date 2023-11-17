//
//  ClearFullScreenCover+View.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/16/23.
//
// https://stackoverflow.com/questions/64301041/swiftui-translucent-background-for-fullscreencover

import Foundation
import SwiftUI

struct ClearFullScreenCoverView: UIViewRepresentable {
    
//    private let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))//UIView()
//        let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        blurBackground.frame = view.bounds
        view.alpha = 0.0
        
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
            
            UIView.animate(withDuration: 0.4, delay: 0.1, animations: {
                view.alpha = 1.0
            })
        }
        
//        view.addSubview(blurBackground)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension View {
    
    func clearFullScreenCover<Content: View>(isPresented: Binding<Bool>, onDismiss: (()->Void)? = nil, @ViewBuilder content: @escaping ()->Content) -> some View {
        self
            .fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: {
                ZStack {
                    Color.clear
                    
                    content()
                        .transition(.opacity)
                }
                .background(ClearFullScreenCoverView()
                    .ignoresSafeArea())
            })
    }
    
}
