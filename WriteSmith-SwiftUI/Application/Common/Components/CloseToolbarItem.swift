//
//  CloseToolbarItem.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import SwiftUI

struct CloseToolbarItem: ToolbarContent {
    
    @Binding var isPresented: Bool
    
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                isPresented = false
            }) {
                Text("Close")
                    .font(.custom(Constants.FontName.body, size: 17.0))
            }
            .foregroundStyle(Colors.elementTextColor)
        }
    }
    
}

#Preview {
    ZStack {
        
    }
    .toolbar {
        CloseToolbarItem(isPresented: .constant(true))
    }
}
