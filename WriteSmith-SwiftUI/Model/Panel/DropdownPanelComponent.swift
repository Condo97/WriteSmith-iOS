//
//  DropdownPanelComponent.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation

struct DropdownPanelComponent: Identifiable, Codable, Hashable {
    
    var id = UUID()
    
    var placeholder: String?
    var options: [String]
    
    enum CodingKeys: String, CodingKey {
        case placeholder
        case options
    }
    
    
    private let defaultPlaceholder = "Tap to select..."
    
    var placeholderUnwrapped: String {
        placeholder ?? defaultPlaceholder
    }
    
}
