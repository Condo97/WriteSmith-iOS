//
//  PanelParser.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/29/23.
//

import Foundation

class PanelParser {
    
    fileprivate struct PanelGroupArray: Codable {
        
        var panelGroups: [PanelGroup]
        
        enum CodingKeys: String, CodingKey {
            case panelGroups
        }
        
    }
    
    static func parsePanelGroups(fromJson json: String) throws -> [PanelGroup]? {
        guard let jsonData = json.data(using: .utf8) else {
            // TODO: Handle errors if necessary
            return nil
        }
        
        return try parsePanelGroups(fromJsonData: jsonData)
    }
    
    static func parsePanelGroups(fromJsonData jsonData: Data) throws -> [PanelGroup]? {
        try JSONDecoder().decode(PanelGroupArray.self, from: jsonData).panelGroups
    }
    
}
