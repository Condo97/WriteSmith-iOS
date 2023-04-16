//
//  ConstantsHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

class ConstantsHelper {
    
    static func update() {
        HTTPSConnector.getImportantConstants(completion: {response in
            if response.success != 1 {
                // Update constants if nil, since the server returned an error
                setIfNil(Constants.defaultShareURL, forKey: Constants.userDefaultStoredShareURL)
                setIfNil(Constants.defaultFreeEssayCap, forKey: Constants.userDefaultStoredFreeEssayCap)
                setIfNil(Constants.defaultWeeklyDisplayPrice, forKey: Constants.userDefaultStoredWeeklyDisplayPrice)
                setIfNil(Constants.defaultMonthlyDisplayPrice, forKey: Constants.userDefaultStoredMonthlyDisplayPrice)
            }
            
            // Update constants
            UserDefaults.standard.set(response.body.shareURL, forKey: Constants.userDefaultStoredShareURL)
            UserDefaults.standard.set(response.body.freeEssayCap, forKey: Constants.userDefaultStoredFreeEssayCap)
            UserDefaults.standard.set(response.body.weeklyDisplayPrice, forKey: Constants.userDefaultStoredWeeklyDisplayPrice)
            UserDefaults.standard.set(response.body.monthlyDisplayPrice, forKey: Constants.userDefaultStoredMonthlyDisplayPrice)
        })
    }
    
    private static func setIfNil(_ value: Any, forKey key: String) {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
}
