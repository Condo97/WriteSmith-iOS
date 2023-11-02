//
//  Keys.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/30/23.
//

import Foundation

struct Keys {
    
    struct Ads {
        
        struct Banner {
            
        #if DEBUG
            static let chatView = "ca-app-pub-3940256099942544/2934735716"
        #else
            static let chatView = "ca-app-pub-7814704845493911/8427792964"
        #endif
            
            static let conversationView = "ca-app-pub-7814704845493911/9668349333"
            static let debug = "ca-app-pub-3940256099942544/2934735716"
            static let essayView = "ca-app-pub-7814704845493911/4751064574"
            static let exploreChatView = "ca-app-pub-7814704845493911/2665571683"
            static let exploreView = "ca-app-pub-7814704845493911/6811085859"
            static let panelView = "ca-app-pub-7814704845493911/6740548066"
            static let settingsView = "ca-app-pub-7814704845493911/5737429918"
            
        }
        
        struct Interstitial {
            
        #if DEBUG
            static let chatView = "ca-app-pub-3940256099942544/4411468910"
        #else
            static let chatView = "ca-app-pub-7814704845493911/7023318127"
        #endif
            
            static let debug = "ca-app-pub-3940256099942544/4411468910"
            static let essayView = "ca-app-pub-7814704845493911/1637568656"
            static let panelView = "ca-app-pub-7814704845493911/6073854720"
            
        }
        
    }
    
    static let sharedSecret = "57f880d1fff94a2a8595576969eea83b"
    
}
