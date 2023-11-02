//
//  Panel.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation

struct Panel: Identifiable, Codable, Hashable {
    
    var id = UUID()
    
    var imageName: String?
    var emoji: String?
    var title: String
    var description: String
    var prompt: String?
    var components: [PanelComponent]
    
    enum CodingKeys: String, CodingKey {
        case imageName
        case emoji
        case title
        case description
        case prompt
        case components
    }
    
}
