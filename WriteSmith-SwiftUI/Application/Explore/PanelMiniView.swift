//
//  PanelMiniView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct PanelMiniView: View {
    
    @State var imageName: String?
    @State var emoji: String?
    @State var title: String
    @State var description: String
    
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 4.0) {
                    HStack {
//                        if let image = emoji.toImage(fontName: Constants.FontName.body) {
//                            Image(uiImage: image)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: geometry.size.width * 0.22)
//                                .padding([.leading, .trailing], 4)
//                        }
                        if let imageName = imageName, let uiImage = UIImage(named: imageName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.22)
                                .padding([.leading, .trailing], 4)
                        } else if let emoji = emoji {
                            Text(emoji)
                                .font(.system(size: 34.0))
                        }
                        
                        Text(title)
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Text(description)
                        .font(.custom(Constants.FontName.body, size: 11.0))
                        .multilineTextAlignment(.leading)
                        .opacity(0.8)
                }
            }
        }
        .padding(12)
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 24.0))
    }
    
}

#Preview {
    PanelMiniView(
        imageName: nil,
        emoji: "🎶",
        title: "This is the title",
        description: "This is the description. This is the description. This is the description. This is the description. This is the description. This is the description."
    )
        .frame(width: 170, height: 120)
        .background(Colors.background)
}
