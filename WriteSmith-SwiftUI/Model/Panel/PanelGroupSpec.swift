//
//  PanelGroupSpec.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation

struct PanelGroupSpec {
    
    static var panelGroups: [PanelGroup] = [
        PanelGroup(
            name: "First Group",
            panels: [
                Panel(
                    emoji: "🎶",
                    title: "The title",
                    description: "The description",
                    prompt: "The prompt",
                    components: [
                        PanelComponent(
                            type: .dropdown(
                                DropdownPanelComponent(
                                    placeholder: "Placeholder",
                                    options: [
                                        "Option 1",
                                        "Option 2",
                                        "Option 3"
                                    ])),
                            titleText: "Title Text",
                            detailTitle: "Detail Title",
                            detailText: "Detail Text",
                            promptPrefix: "Prompt Prefix",
                            required: true),
                        PanelComponent(
                            type: .textField(
                                TextFieldPanelComponent(
                                    placeholder: "placeholder"
                                )),
                            titleText: "Text Field Title Text",
                            detailTitle: "Text Field Detail Title",
                            detailText: "Text Field Detail Text",
                            promptPrefix: "Text Field Prompt Prefix",
                            required: false)
                    ]),
                Panel(
                    emoji: "🍆",
                    title: "Another title",
                    description: "Another description",
                    prompt: "Another prompt",
                    components: [
                        PanelComponent(
                            type: .dropdown(
                                DropdownPanelComponent(
                                    placeholder: "Placeholder",
                                    options: [
                                        "Option 1",
                                        "Option 2",
                                        "Option 3"
                                    ])),
                            titleText: "Title Text",
                            detailTitle: "Detail Title",
                            detailText: "Detail Text",
                            promptPrefix: "Prompt Prefix",
                            required: true),
                        PanelComponent(
                            type: .textField(
                                TextFieldPanelComponent(
                                    placeholder: "placeholder"
                                )),
                            titleText: "Text Field Title Text",
                            detailTitle: "Text Field Detail Title",
                            detailText: "Text Field Detail Text",
                            promptPrefix: "Text Field Prompt Prefix",
                            required: false)
                    ])
            ]),
        PanelGroup(
            name: "Second Group",
            panels: [
                Panel(
                    emoji: "🎶",
                    title: "The title",
                    description: "The description",
                    prompt: "The prompt",
                    components: [
                        PanelComponent(
                            type: .dropdown(
                                DropdownPanelComponent(
                                    placeholder: "Placeholder",
                                    options: [
                                        "Option 1",
                                        "Option 2",
                                        "Option 3"
                                    ])),
                            titleText: "Title Text",
                            detailTitle: "Detail Title",
                            detailText: "Detail Text",
                            promptPrefix: "Prompt Prefix",
                            required: true),
                        PanelComponent(
                            type: .textField(
                                TextFieldPanelComponent(
                                    placeholder: "placeholder"
                                )),
                            titleText: "Text Field Title Text",
                            detailTitle: "Text Field Detail Title",
                            detailText: "Text Field Detail Text",
                            promptPrefix: "Text Field Prompt Prefix",
                            required: false)
                    ]),
                Panel(
                    emoji: "🍆",
                    title: "Another title",
                    description: "Another description",
                    prompt: "Another prompt",
                    components: [
                        PanelComponent(
                            type: .dropdown(
                                DropdownPanelComponent(
                                    placeholder: "Placeholder",
                                    options: [
                                        "Option 1",
                                        "Option 2",
                                        "Option 3"
                                    ])),
                            titleText: "Title Text",
                            detailTitle: "Detail Title",
                            detailText: "Detail Text",
                            promptPrefix: "Prompt Prefix",
                            required: true),
                        PanelComponent(
                            type: .textField(
                                TextFieldPanelComponent(
                                    placeholder: "placeholder"
                                )),
                            titleText: "Text Field Title Text",
                            detailTitle: "Text Field Detail Title",
                            detailText: "Text Field Detail Text",
                            promptPrefix: "Text Field Prompt Prefix",
                            required: false)
                    ])
            ])
    ]
    
}
