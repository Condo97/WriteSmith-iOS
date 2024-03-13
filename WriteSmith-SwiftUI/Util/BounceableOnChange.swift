//
//  BounceableOnChange.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/11/23.
//

import Foundation
import SwiftUI

struct BounceableOnChange: ViewModifier {
    
    @State var bounceDuration: CGFloat = 0.2
    @Binding var bounce: Bool
    
    
    @State private var isBouncing: Bool = false
    
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isBouncing ? 0.9 : 1.0)
            .opacity(isBouncing ? 0.8 : 1.0)
            .onChange(of: bounce, perform: { value in
                if bounce {
                    Task {
                        do {
                            try await doBounce()
                        } catch {
                            print("Error bouncing in BounceableOnChange")
                        }
                    }
                }
            })
    }
    
    func doBounce() async throws {
        // Ensure is not bouncing, otherwise return
        guard !isBouncing else {
            return
        }
        
        // Defer setting isBouncing and bounce to false to ensure it is always set
        defer {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: bounceDuration)) {
                    isBouncing = false
                    bounce = false
                }
            }
        }
        
        // Animate bounce in
        await MainActor.run {
            withAnimation(.easeInOut(duration: bounceDuration)) {
                isBouncing = true
            }
        }
        
        // Wait before animating bounce out
        try await Task.sleep(nanoseconds: UInt64(bounceDuration * CGFloat(1_000_000_000)))
    }
    
}

extension View {
    
    func bounceableOnChange(bounce: Binding<Bool>) -> some View {
        modifier(BounceableOnChange(bounce: bounce))
    }
    
}
