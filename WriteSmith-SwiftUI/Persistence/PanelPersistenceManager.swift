//
//  PanelPersistenceManager.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/29/23.
//

import Foundation

class PanelPersistenceManager {
    
    private static let panelJSONFileName = "WriteSmithPanelSpec"
    
    
    static func get() -> String? {
//        if let panelGroupsJSON = UserDefaults.standard.string(forKey: Constants.UserDefaults.panelGroupsJSON) {
//            // If panelGroupsJSON is
//            
//            return panelGroupsJSON
//        }
        
        do {
            // If jsonString can be unwrapped set in UesrDefaults and return it, otherwise return nil
            if let jsonString = try readJSONFromFile(name: panelJSONFileName) {
                
                set(jsonString)
                
                return jsonString
            }
            
            return nil
        } catch {
            // TODO: Handle errors if necessary
            print("Error reading JSON from file... \(error)")
            return nil
        }
    }
    
    static func set(_ jsonString: String) {
        UserDefaults.standard.set(jsonString, forKey: Constants.UserDefaults.panelGroupsJSON)
    }
    
    private static func readJSONFromFile(name: String) throws -> String? {
        if let bundlePath = Bundle.main.path(forResource: name, ofType: "json") {
            return try String(contentsOfFile: bundlePath)
        }
        
        return nil
    }
    
}
