//
//  CameraButtonView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import SwiftUI

struct CameraButtonView: View {
    
    var initialHeight: CGFloat
    var action: () -> Void
    
    
    var body: some View {
        KeyboardDismissingButton(action: {
            action()
        }) {
            Image(systemName: "camera.viewfinder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: initialHeight)
                .padding()
                .foregroundStyle(Colors.elementTextColor)
                .background(Colors.elementBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        }
            
    }
    
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    CameraButtonView(initialHeight: 32.0, action: {
        
    })
}
