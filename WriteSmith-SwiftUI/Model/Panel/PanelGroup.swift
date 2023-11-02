//
//  PanelGroup.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation

struct PanelGroup: Identifiable, Codable, Hashable {
    
    var id = UUID()
    
    var name: String
    var panels: [Panel]
    
    enum CodingKeys: String, CodingKey {
        case name
        case panels
    }
    
}
