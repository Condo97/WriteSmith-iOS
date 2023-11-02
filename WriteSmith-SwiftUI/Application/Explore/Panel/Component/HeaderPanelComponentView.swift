//
//  HeaderPanelComponentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct HeaderPanelComponentView: View {
    
    @Binding var imageName: String?
    @Binding var emoji: String?
    @Binding var title: String
    @Binding var description: String
    
    
    var body: some View {
        HStack {
            Spacer()
            
            if let imageName = imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80.0)
            } else if let emoji = emoji {
                Text(emoji)
                    .font(.system(size: 34.0))
                    .padding()
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.custom(Constants.FontName.heavy, size: 24.0))
                
                Text(description)
                    .font(.custom(Constants.FontName.body, size: 14.0))
            }
            .foregroundStyle(Colors.text)
            
            Spacer()
        }
        .foregroundStyle(Colors.text)
        .padding()
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
    }
    
}

@available(iOS 17.0, *)
#Preview {
    HeaderPanelComponentView(
        imageName: .constant("Instagram"),
        emoji: .constant("🎶"),
        title: .constant("Title"),
        description: .constant("This is the description. This is the description. This is the description. This is the description. This is the description.")
    )
    .background(Colors.background)
}
