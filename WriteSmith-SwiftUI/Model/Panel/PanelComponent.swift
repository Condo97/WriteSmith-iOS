//
//  PanelComponent.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation

struct PanelComponent: Identifiable, Codable, Hashable {
    
    var id = UUID()
    
    var type: PanelComponentType
    var titleText: String
    var detailTitle: String?
    var detailText: String?
    var promptPrefix: String?
    var required: Bool?
    
    var finalizedPrompt: String?
    
    
    enum CodingKeys: String, CodingKey {
        case type
        case titleText
        case detailTitle
        case detailText
        case promptPrefix
        case required
    }
    
    
    private let defaultRequired = false
    
    private enum PanelComponentTypeIdentifiers: String {
        case dropdown = "dropdown"
        case textField = "textField"
    }
    
    var requiredUnwrapped: Bool {
        get {
            required ?? defaultRequired
        }
        set {
            required = newValue
        }
    }
    
}

extension PanelComponent {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.titleText = try container.decode(String.self, forKey: .titleText)
        self.detailTitle = try container.decodeIfPresent(String.self, forKey: .detailTitle)
        self.detailText = try container.decodeIfPresent(String.self, forKey: .detailText)
        self.promptPrefix = try container.decodeIfPresent(String.self, forKey: .promptPrefix)
        self.required = try container.decodeIfPresent(Bool.self, forKey: .required)
        
        let typeString = try container.decodeIfPresent(String.self, forKey: .type)
        switch typeString?.lowercased() {
        case PanelComponentTypeIdentifiers.dropdown.rawValue.lowercased():
            type = .dropdown(try DropdownPanelComponent(from: decoder))
        case PanelComponentTypeIdentifiers.textField.rawValue.lowercased():
            type = .textField(try TextFieldPanelComponent(from: decoder))
        default:
            throw DecodingError.valueNotFound(PanelComponentType.self, DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "Could not find a valid value for \"type\" in the JSON. Please check your spelling and make sure you are using a valid type name."))
        }
    }
    
}
