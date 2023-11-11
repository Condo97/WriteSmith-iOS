//
//  ShareToolbarItem.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import SwiftUI

struct ShareToolbarItem: ToolbarContent {
    
    @Binding var elementColor: Color
    @State var placement: ToolbarItemPlacement
    @State var tightenLeadingSpacing: Bool = false
    @State var tightenTrailingSpacing: Bool = false
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            VStack {
                ShareLink(item: Constants.UserDefaults.userDefaultStoredShareURL) {
                    Spacer()
                    Image(Constants.ImageName.share)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .padding(2)
                }
                .onTapGesture {
                    // Do light haptic
                    HapticHelper.doLightHaptic()
                }
                .foregroundStyle(elementColor)
                .padding(.leading, tightenLeadingSpacing ? -15.0 : 0.0)
                .padding(.trailing, tightenTrailingSpacing ? -15.0 : 0.0)
//                .padding(.top, 4)
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        ZStack {
            
        }
        .toolbar {
            ShareToolbarItem(elementColor: .constant(Colors.elementTextColor), placement: .topBarLeading)
        }
        .toolbarBackground(Colors.elementBackgroundColor)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}
