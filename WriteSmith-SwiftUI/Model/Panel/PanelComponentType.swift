//
//  PanelComponentType.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation

enum PanelComponentType: Codable, Hashable {
    
    case textField(TextFieldPanelComponent)
    case dropdown(DropdownPanelComponent)
    
}
