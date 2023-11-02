//
//  SettingsToolbarItem.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/29/23.
//

import SwiftUI

struct SettingsToolbarItem: ToolbarContent {
    
    @Binding var elementColor: Color
    @State var placement: ToolbarItemPlacement
    @State var tightenLeadingSpacing: Bool = false
    @State var tightenTrailingSpacing: Bool = false
    var action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement, content: {
            VStack {
                Button(action: {
                    action()
                }) {
                    Spacer()
                    Image(systemName: "gear")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                }
                .foregroundStyle(elementColor)
                .padding(.leading, tightenLeadingSpacing ? -12.0 : 0.0)
                .padding(.trailing, tightenTrailingSpacing ? -12.0 : 0.0)
//                .padding(.top, 4)
            }
        })
    }
}

#Preview {
    NavigationStack {
        ZStack {
            
        }
        .toolbar {
            SettingsToolbarItem(elementColor: .constant(Colors.elementTextColor), placement: .topBarLeading, action: {
                
            })
        }
    }
}
