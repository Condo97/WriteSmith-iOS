//
//  ConstantsHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/31/23.
//

import Foundation

class ConstantsHelper {
    
    static func update() async throws {
        let response = try await HTTPSConnector.getImportantConstants()
        if response.success != 1 {
            // Update constants if nil, since the server returned an error
            setIfNil(Constants.defaultShareURL, forKey: Constants.UserDefaults.userDefaultStoredShareURL)
            setIfNil(Constants.defaultFreeEssayCap, forKey: Constants.UserDefaults.userDefaultStoredFreeEssayCap)
            setIfNil(Constants.defaultWeeklyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredWeeklyDisplayPrice)
            setIfNil(Constants.defaultMonthlyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredMonthlyDisplayPrice)
        }
        
        // Update constants
        UserDefaults.standard.set(response.body.shareURL, forKey: Constants.UserDefaults.userDefaultStoredShareURL)
        UserDefaults.standard.set(response.body.freeEssayCap, forKey: Constants.UserDefaults.userDefaultStoredFreeEssayCap)
        UserDefaults.standard.set(response.body.weeklyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredWeeklyDisplayPrice)
        UserDefaults.standard.set(response.body.monthlyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredMonthlyDisplayPrice)
    }
    
    private static func setIfNil(_ value: Any, forKey key: String) {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
}
