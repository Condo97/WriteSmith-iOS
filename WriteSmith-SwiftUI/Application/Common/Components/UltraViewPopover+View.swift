//
//  View+UltraViewPopover+View.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/8/23.
//

import Foundation
import SwiftUI

struct UltraViewPopover: ViewModifier {
    
    @ObservedObject var premiumUpdater: PremiumUpdater
    @Binding var isPresented: Bool
    @Binding var restoreOnAppear: Bool
    
    
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    func body(content: Content) -> some View {
        if horizontalSize == .regular {
            content
                .sheet(isPresented: $isPresented, content: {
                    UltraView(
                        premiumUpdater: premiumUpdater,
                        restoreOnAppear: $restoreOnAppear,
                        isShowing: $isPresented)
                })
        } else {
            content
                .fullScreenCover(isPresented: $isPresented, content: {
                    UltraView(
                        premiumUpdater: premiumUpdater,
                        restoreOnAppear: $restoreOnAppear,
                        isShowing: $isPresented)
                })
        }
    }
    
}

extension View {
    
    func ultraViewPopover(isPresented: Binding<Bool>, restoreOnAppear: Binding<Bool> = .constant(false), premiumUpdater: PremiumUpdater) -> some View {
        self
            .modifier(UltraViewPopover(
                premiumUpdater: premiumUpdater,
                isPresented: isPresented,
                restoreOnAppear: restoreOnAppear))
    }
    
}

