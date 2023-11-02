//
//  EntryView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import SwiftUI

struct EntryView: View {
    
    @Binding var text: String
    let initialHeight: CGFloat
    var buttonDisabled: Bool = false
    var onSubmit: () -> Void
    
    
//    private let initialHeight: CGFloat = 32.0
    
    var body: some View {
        HStack(alignment: .bottom) {
            TextField("", text: $text, axis: .vertical)
                .textFieldTickerTint(Colors.elementTextColor)
                .placeholder(when: text.isEmpty, placeholder: {
                    Text("Tap to start chatting...")
                })
                .dismissOnReturn()
                .font(.custom(Constants.FontName.medium, size: 20.0))
                .foregroundStyle(Colors.elementTextColor)
                .frame(minHeight: initialHeight)
            
            VStack {
                KeyboardDismissingButton(action: {
                    onSubmit()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28.0)
                        .foregroundStyle(Colors.elementTextColor)
                }
                .disabled(buttonDisabled)
                .opacity(buttonDisabled ? 0.4 : 1.0)
            }
            .frame(height: initialHeight)
        }
        .onChange(of: buttonDisabled, perform: { value in
            print("REE")
        })
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        .background(Colors.elementBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
    }
    
//    func buttonsDisabled(_ disabled: Bool) -> EntryView {
//        var newView = self
//        newView._buttonDisabled = State(initialValue: disabled)
//        return newView
//    }
    
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    EntryView(
        text: .constant(""),
        initialHeight: 32.0,
        buttonDisabled: false,
        onSubmit: {
            
        })
}
