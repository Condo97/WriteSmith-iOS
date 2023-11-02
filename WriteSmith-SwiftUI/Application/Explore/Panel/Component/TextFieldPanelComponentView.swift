//
//  TextFieldPanelComponentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct TextFieldPanelComponentView: ComponentView {
    
    @State var titleText: String
    @State var placeholder: String
    @State var multiline: Bool
    @State var promptPrefix: String?
    @State var required: Bool
    
    @Binding var finalizedPrompt: String?
    
    
    @State private var textFieldText: String = ""
    
    var body: some View {
        VStack(spacing: 4.0) {
            TitlePanelComponentView(
                text: titleText,
                required: required)
            TextField("", text: $textFieldText, axis: multiline ? .vertical : .horizontal)
                .lineLimit(multiline ? 999 : 1)
                .frame(minHeight: multiline ? 80.0 : 0.0, alignment: .topLeading)
                .textFieldTickerTint(Colors.elementBackgroundColor)
                .placeholder(
                    when: textFieldText.isEmpty,
                    alignment: .topLeading,
                    placeholder: {
                        Text(placeholder)
                            .opacity(0.6)
                    })
                .dismissOnReturn()
//                .keyboardDismissingTextFieldToolbar("Done", color: Colors.buttonBackground)
                .font(.custom(Constants.FontName.body, size: 17.0))
                .foregroundStyle(Colors.text)
                .padding()
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                .onChange(of: textFieldText) { newValue in
                    updateFinalizedPrompt()
                }
            
        }
    }
    
    private func updateFinalizedPrompt() {
        guard !textFieldText.isEmpty else {
            finalizedPrompt = nil
            return
        }
        
        finalizedPrompt = (promptPrefix == nil ? "" : promptPrefix! + " ") + textFieldText
    }
    
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    
    TextFieldPanelComponentView(
        titleText: "Title text",
        placeholder: "Placeholder",
        multiline: true,
        promptPrefix: "asdfadfasdf",
        required: true,
        finalizedPrompt: .constant("adsfasdf")
    )
    .background(Colors.background)
    
}
