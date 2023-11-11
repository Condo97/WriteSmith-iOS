//
//  UltraButton.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import SwiftUI

struct UltraButton: View {
    
    @ObservedObject var premiumUpdater: PremiumUpdater
    @ObservedObject var remainingUpdater: RemainingUpdater
    @State var sparkleDiameter: CGFloat = 28.0
    @State var fontSize: CGFloat = 20.0
    @State var cornerRadius: CGFloat = 10
    @State var horizontalSpacing: CGFloat = 4.0
    @State var innerPadding: CGFloat = 8.0
    @State var lineWidth: CGFloat = 2.0
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    @State private var isShowingUltraView: Bool = false
    
    private var sparkleImageName: String {
        colorScheme == .dark ? Constants.ImageName.sparkleDarkGif : Constants.ImageName.sparkleLightGif
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                // Show Ultra View
                isShowingUltraView = true
                
                // Do light haptic
                HapticHelper.doLightHaptic()
            }) {
                HStack(spacing: horizontalSpacing) {
                    SwiftyGif(name: sparkleImageName)
                        .frame(width: sparkleDiameter, height: sparkleDiameter)
                    
                    Text("\(remainingUpdater.remaining ?? 0)")
                        .font(.custom(Constants.FontName.black, size: fontSize))
                }
                .foregroundStyle(Colors.elementBackgroundColor)
                .padding(innerPadding)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Colors.elementTextColor)
                )
            }
            .bounceable()
        }
        .ultraViewPopover(
            isPresented: $isShowingUltraView,
            premiumUpdater: premiumUpdater)
    }
    
}

#Preview {
    UltraButton(
        premiumUpdater: PremiumUpdater(),
        remainingUpdater: RemainingUpdater())
        .background(.yellow)
}
