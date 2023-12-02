//
//  UltraToolbarItem.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import SwiftUI

struct UltraToolbarItem: ToolbarContent {
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    @EnvironmentObject var remainingUpdater: RemainingUpdater
    
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            UltraButton(
                sparkleDiameter: 19.0,
                fontSize: 14.0,
                cornerRadius: 8.0,
                horizontalSpacing: 2.0,
                innerPadding: 5.0,
                lineWidth: 1.5)
        }
    }
    
}

#Preview {
    NavigationStack {
        ZStack {
            
        }
        .toolbar {
            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
            
            AddChatToolbarItem(elementColor: .constant(Colors.elementTextColor), trailingPadding: -12, action: {
                
            })
            
            UltraToolbarItem()
        }
        .toolbarBackground(Colors.elementBackgroundColor)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(RemainingUpdater())
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
    }
}
