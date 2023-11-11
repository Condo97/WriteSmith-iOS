//
//  ConstantsHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/31/23.
//

import Foundation

class ConstantsHelper {
    
    static var shareURL: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredShareURL) ?? Constants.defaultShareURL.absoluteString
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.userDefaultStoredShareURL)
        }
    }
    
    static var freeEssayCap: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UserDefaults.userDefaultStoredFreeEssayCap) == 0 ? Constants.defaultFreeEssayCap : UserDefaults.standard.integer(forKey: Constants.UserDefaults.userDefaultStoredFreeEssayCap)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.userDefaultStoredFreeEssayCap)
        }
    }
    
    static var weeklyDisplayPrice: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredWeeklyDisplayPrice) ?? Constants.defaultWeeklyDisplayPrice
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.userDefaultStoredWeeklyDisplayPrice)
        }
    }
    
    static var monthlyDisplayPrice: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredMonthlyDisplayPrice) ?? Constants.defaultMonthlyDisplayPrice
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.userDefaultStoredMonthlyDisplayPrice)
        }
    }
    
    static var appLaunchAlert: String? {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.appLaunchAlert)
        }
        set {
            let trimmedNewValue: String? = {
                var trimmedValue = newValue?.trimmingCharacters(in: .whitespaces)
                return trimmedValue == nil || trimmedValue!.isEmpty ? nil : trimmedValue!
            }()
            
            UserDefaults.standard.setValue(trimmedNewValue, forKey: Constants.UserDefaults.appLaunchAlert)
        }
    }
    
    
    static func update() async throws {
        let response = try await HTTPSConnector.getImportantConstants()
//        if response.success != 1 {
//            // Update constants if nil, since the server returned an error
//            setIfNil(Constants.defaultShareURL, forKey: Constants.UserDefaults.userDefaultStoredShareURL)
//            setIfNil(Constants.defaultFreeEssayCap, forKey: Constants.UserDefaults.userDefaultStoredFreeEssayCap)
//            setIfNil(Constants.defaultWeeklyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredWeeklyDisplayPrice)
//            setIfNil(Constants.defaultMonthlyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredMonthlyDisplayPrice)
//        }
//        
//        // Update constants
//        UserDefaults.standard.set(response.body.shareURL, forKey: Constants.UserDefaults.userDefaultStoredShareURL)
//        UserDefaults.standard.set(response.body.freeEssayCap, forKey: Constants.UserDefaults.userDefaultStoredFreeEssayCap)
//        UserDefaults.standard.set(response.body.weeklyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredWeeklyDisplayPrice)
//        UserDefaults.standard.set(response.body.monthlyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredMonthlyDisplayPrice)
        
        shareURL = response.body.shareURL
        freeEssayCap = response.body.freeEssayCap
        weeklyDisplayPrice = response.body.weeklyDisplayPrice
        monthlyDisplayPrice = response.body.monthlyDisplayPrice
        appLaunchAlert = response.body.appLaunchAlert
    }
    
    private static func setIfNil(_ value: Any, forKey key: String) {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
}
