//
//  LogoToolbarItem.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/20/23.
//

import SwiftUI

struct LogoToolbarItem: ToolbarContent {
    
    @Binding var elementColor: Color
    
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Spacer()
                Image(Constants.ImageName.logo)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(elementColor)
                    .frame(height: 38)
                    .padding(.bottom, 8)
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        ZStack {
            
        }
        .toolbar {
            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
        }
        .toolbarBackground(Colors.elementBackgroundColor)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}
