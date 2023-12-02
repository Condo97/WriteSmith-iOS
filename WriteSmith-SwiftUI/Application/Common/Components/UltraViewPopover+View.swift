//
//  View+UltraViewPopover+View.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/8/23.
//

import Foundation
import SwiftUI

struct UltraViewPopover: ViewModifier {
    
    @Binding var isPresented: Bool
    @Binding var restoreOnAppear: Bool
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    
    
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    func body(content: Content) -> some View {
        if horizontalSize == .regular {
            content
                .sheet(isPresented: $isPresented, content: {
                    UltraView(
                        restoreOnAppear: $restoreOnAppear,
                        isShowing: $isPresented)
                })
        } else {
            content
                .fullScreenCover(isPresented: $isPresented, content: {
                    UltraView(
                        restoreOnAppear: $restoreOnAppear,
                        isShowing: $isPresented)
                })
        }
    }
    
}

extension View {
    
    func ultraViewPopover(isPresented: Binding<Bool>, restoreOnAppear: Binding<Bool> = .constant(false)) -> some View {
        self
            .modifier(UltraViewPopover(
                isPresented: isPresented,
                restoreOnAppear: restoreOnAppear))
    }
    
}

