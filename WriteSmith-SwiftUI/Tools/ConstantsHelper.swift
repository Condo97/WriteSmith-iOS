//
//  ConstantsHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/31/23.
//

import Foundation

class ConstantsHelper {
    
    private static let priceVAR1Suffix = "VAR1"
    private static let priceVAR2Suffix = "VAR2"
    
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
    
    static var sharedSecret: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredSharedSecret) ?? Constants.fallbackSharedSecret
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.userDefaultStoredSharedSecret)
        }
    }
    
    static var iapVarientSuffix: String? {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredIAPVarientSuffix)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaults.userDefaultStoredIAPVarientSuffix)
        }
    }
    
    static var weeklyProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredWeeklyProductID) ?? Constants.fallbackWeeklyProductIdentifier
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.userDefaultStoredWeeklyProductID)
        }
    }
    
    static var monthlyProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredMonthlyProductID) ?? Constants.fallbackMonthlyProductIdentifier
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.userDefaultStoredMonthlyProductID)
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
        appLaunchAlert = response.body.appLaunchAlert
        
        if let responseSharedSecret = response.body.sharedSecret {
            sharedSecret = responseSharedSecret
        }
        
        // Check if iapVarientSuffix is nil or empty, and if so do chance calculation based on priceVAR2DisplayChance and set iapVarientSuffix
        if iapVarientSuffix == nil || iapVarientSuffix!.isEmpty, let priceVAR2DisplayChance = response.body.priceVAR2DisplayChance {
            // Get random double
            let randomDouble = Double.random(in: 0..<1)
            
            // Since we're getting a percentage that the price will be VAR2, we can create a random number between 0-1 and check if it is less than priceVAR2DisplayChance.. for example, it the priceVAR2DisplayChance is 0.8, check if our random number is less than or equal to 0.8 and if so then set suffix to VAR2 otherwise VAR1
            iapVarientSuffix = randomDouble < priceVAR2DisplayChance ? priceVAR2Suffix : priceVAR1Suffix
        }
        
        // Set weekly and monthly productID and displayPrice by iapVarientSuffix
        if iapVarientSuffix == priceVAR2Suffix {
            // Set VAR2
            if let responseWeeklyProductID = response.body.weeklyProductID_VAR2 {
                weeklyProductID = responseWeeklyProductID
            }
            
            if let responseMonthlyProductID = response.body.monthlyProductID_VAR2 {
                monthlyProductID = responseMonthlyProductID
            }
            
            if let responseWeeklyDisplayPrice = response.body.weeklyDisplayPrice_VAR2 {
                weeklyDisplayPrice = responseWeeklyDisplayPrice
            }
            
            if let responseMonthlyDisplayPrice = response.body.monthlyDisplayPrice_VAR2 {
                monthlyDisplayPrice = responseMonthlyDisplayPrice
            }
        } else {
            // Default to VAR1
            if let responseWeeklyProductID = response.body.weeklyProductID_VAR1 {
                weeklyProductID = responseWeeklyProductID
            }
            
            if let responseMonthlyProductID = response.body.monthlyProductID_VAR1 {
                monthlyProductID = responseMonthlyProductID
            }
            
            if let responseWeeklyDisplayPrice = response.body.weeklyDisplayPrice_VAR1 {
                weeklyDisplayPrice = responseWeeklyDisplayPrice
            }
            
            if let responseMonthlyDisplayPrice = response.body.monthlyDisplayPrice_VAR1 {
                monthlyDisplayPrice = responseMonthlyDisplayPrice
            }
        }
        
    }
    
    private static func setIfNil(_ value: Any, forKey key: String) {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
}
