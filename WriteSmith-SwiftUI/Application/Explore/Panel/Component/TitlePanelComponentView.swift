//
//  TitlePanelComponentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation
import SwiftUI

struct TitlePanelComponentView: View {
    
    @State var text: String
    @State var detailTitle: String?
    @State var detailText: String?
    @State var required: Bool
    
    
    @State private var alertShowingInfo = false
    
    var body: some View {
        HStack {
            Text(text)
                .font(.custom(Constants.FontName.body, size: 20.0))
            +
            Text(required ? " *" : " (optional)")
                .font(required ? .custom(Constants.FontName.body, size: 20.0) : .custom(Constants.FontName.lightOblique, size: 17.0))
            
            if let detailTitle = detailTitle, let detailText = detailText {
                KeyboardDismissingButton(action: {
                    alertShowingInfo = true
                }) {
                    Text(Image(systemName: "info.circle"))
                        .font(.custom(Constants.FontName.body, size: 24.0))
                }
                .foregroundStyle(Colors.buttonBackground)
            }
            
            Spacer()
        }
        .foregroundStyle(Colors.textOnBackgroundColor)
        .alert(detailTitle ?? "", isPresented: $alertShowingInfo, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }) {
            Text(detailText ?? "")
        }
    }
    
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    TitlePanelComponentView(
        text: "Title panel component text",
        detailTitle: "Detail title",
        detailText: "Detail text",
        required: true
    )
}

