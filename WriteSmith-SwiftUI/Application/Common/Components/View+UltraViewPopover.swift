//
//  View+UltraViewPopover.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/8/23.
//

import Foundation
import SwiftUI

extension View {
    
    func ultraViewPopover(isPresented: Binding<Bool>, restoreOnAppear: Binding<Bool> = .constant(false), premiumUpdater: PremiumUpdater) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                UltraView(
                    premiumUpdater: premiumUpdater,
                    restoreOnAppear: restoreOnAppear,
                    isShowing: isPresented)
//                UltraView(
//                    premiumUpdater: premiumUpdater,
//                    isShowing: isPresented,
//                    elementColor: elementColor,
//                    foreground: elementColor)
            }
    }
    
}

