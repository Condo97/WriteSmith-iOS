//
//  AddChatToolbarItem.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import SwiftUI

struct AddChatToolbarItem: ToolbarContent {
    
    @Binding var elementColor: Color
    @State var trailingPadding: CGFloat
    var action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            VStack {
                Button(action: {
                    action()
                }) {
                    Spacer()
                    Image(systemName: "plus.bubble")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                }
                .foregroundStyle(elementColor)
                .padding(.top, 4)
                .padding(.trailing, trailingPadding)
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        ZStack {
            
        }
        .toolbar {
            AddChatToolbarItem(elementColor: .constant(Colors.elementTextColor), trailingPadding: 0.0, action: {
                
            })
        }
        .toolbarBackground(Colors.elementBackgroundColor)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

