//
//  IntroView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/1/23.
//

import SwiftUI

struct IntroView<Content: View>: View {
    
    @State var image: Image
    @ViewBuilder var destination: ()->Content
    
    
    @State private var isShowingNext: Bool = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 40)
            
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Button(action: {
                isShowingNext = true
            }) {
                ZStack {
                    Text("Next...")
                        .font(.custom(Constants.FontName.heavy, size: 24.0))
                    
                    HStack {
                        Spacer()
                        Text(Image(systemName: "chevron.right"))
                    }
                }
            }
            .padding()
            .foregroundStyle(Colors.elementTextColor)
            .background(Colors.buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            .padding()
        }
        .background(Colors.elementBackgroundColor)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingNext, destination: destination)
    }
    
}

#Preview {
    NavigationStack {
        IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot1)!), destination: {
            Text("You've got to the destination!")
                .toolbar(.hidden, for: .navigationBar)
        })
    }
}
