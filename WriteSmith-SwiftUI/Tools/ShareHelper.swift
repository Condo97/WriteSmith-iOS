//
//  ShareHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import Foundation

class ShareHelper {
    
    static var appShareURL: URL {
        if let appShareURLStringFromUserDefaults = UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredShareURL), let appShareURLFromUserDefaults = URL(string: appShareURLStringFromUserDefaults) {
            return appShareURLFromUserDefaults
        }
        
        return Constants.defaultShareURL
    }
    
}
