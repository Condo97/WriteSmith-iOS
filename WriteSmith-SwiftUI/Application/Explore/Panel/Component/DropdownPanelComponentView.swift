//
//  DropdownPanelComponentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct DropdownPanelComponentView: ComponentView {
    
    @State var titleText: String
    @State var selectedOption: String
    @State var options: [String]
    @State var promptPrefix: String?
    @State var required: Bool
    
    @Binding var finalizedPrompt: String?
    
    
    private let noneItem: String = "- None -"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            TitlePanelComponentView(
                text: titleText,
                required: required)
            
            HStack {
                Menu {
                    Picker(
                        "",
                        selection: $selectedOption,
                        content: {
                            ForEach(required ? options : ([noneItem] + options), id: \.self) { option in
                                Text(option)
                                    .font(.custom(Constants.FontName.body, size: 17.0))
                            }
                        })
                    .onChange(of: selectedOption) { newSelectedOption in
                        updateFinalizedPrompt()
                    }
                } label: {
                    HStack {
                        Text(selectedOption)
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        Image(systemName: "chevron.up.chevron.down")
                    }
                }
                    
                Spacer()
            }
            .font(.custom(Constants.FontName.body, size: 17.0))
            .foregroundStyle(Colors.text)
            .tint(Colors.text)
            .padding()
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            
        }
    }
    
    private func updateFinalizedPrompt() {
        // Ensure an item is selected by checking if selected is not empty, otherwise set finalizedPrompt to nil and return
        guard !selectedOption.isEmpty else {
            finalizedPrompt = nil
            return
        }
        
        // Ensure selected item is not noneItem, otherwise set finalizedPrompt to nil and return
        guard selectedOption != noneItem else {
            finalizedPrompt = nil
            return
        }
        
        // Set finalizedPrompt to panelComponent prompt prefix if not nil, a space, and selected item
        finalizedPrompt = (promptPrefix == nil ? "" : promptPrefix! + " ") + selectedOption
    }
    
}

#Preview {
    DropdownPanelComponentView(
        titleText: "Title text",
        selectedOption: "Selected option",
        options: [
            "Option 1",
            "Option 2",
            "Option 3"
        ],
        promptPrefix: "asdfasdf",
        required: true,
        finalizedPrompt: .constant("asdfasdf")
    )
    .background(Colors.background)
}
