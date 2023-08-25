//
//  SettingsHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/9/23.
//

import Foundation

class SettingsHelper {
    
    public static func getReduceMotionSetting() -> Bool {
        UserDefaults.standard.bool(forKey: Constants.userDefaultStoredSettingReduceMotion)
    }
    
    public static func getReduceMotionAccessibility() -> Bool {
        UIAccessibility.isReduceMotionEnabled
    }
    
    public static func shouldReduceMotion() -> Bool {
        getReduceMotionSetting() || getReduceMotionAccessibility()
    }
    
    public static func setReduceMotionSetting(_ reduceMotion: Bool) {
        UserDefaults.standard.set(reduceMotion, forKey: Constants.userDefaultStoredSettingReduceMotion)
    }
    
}
