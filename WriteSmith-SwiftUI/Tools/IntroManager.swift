//
//  IntroManager.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/1/23.
//

import Foundation

class IntroManager {
    
    static var isIntroComplete: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.UserDefaults.userDefaultHasFinishedIntro)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.userDefaultHasFinishedIntro)
        }
    }
    
}
