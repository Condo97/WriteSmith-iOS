//
//  UIConstants.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import UIKit
import Foundation

struct Constants {
    static let bottomButtonGradient = UIColor(named: "BottomButtonGradient")!
    static let chatStorageUserDefaultKey = "chatStorageUserDefaultKey"
    static let pastChatStorageUserDefaultKey = "pastChatStorageUserDefaultKey"
    static let authTokenKey = "authTokenKey"
    static let userDefaultHasFinishedIntro = "hasFinishedIntro"
    static let userDefaultStoredIsPremium = "storedIsPremium"
    static let userDefaultStoredWeeklyDisplayPrice = "weeklyDisplayPrice"
    
    static let shareURL = NSURL(string: "https://apps.apple.com/us/app/chit-chat-ai-chat-with-gpt/id1664039953")!
    
    static let defaultDisplayPrice = "3.99"
    
    static let borderWidth = CGFloat(0.0)
    static let cornerRadius = 14.0
    
    static let primaryFontName = "Avenir-Book"
    static let primaryFontNameBold = "Avenir-Heavy"
    static let primaryFontNameBlack = "Avenir-Black"
    static let primaryFontNameBlackOblique = "Avenir-BlackOblique"
    static let secondaryFontName = "Avenir-Heavy"
}

struct HTTPSConstants {
    static let chitChatServer = "https://chitchatserver.com"
    static let registerUesr = "/registerUser"
    static let getRemaining = "/getRemaining"
    static let getChat = "/getChat"
    static let getProducts = "/getProducts"
    static let validateSaveUpdateReceipt = "/validateAndUpdateReceipt"
    static let getGenerateImage = "/getImageUrlFromGenerateUrl"
    static let getIAPStuff = "/getIAPStuff"
    static let privacyPolicy = "/privacyPolicy.html"
    static let termsAndConditions = "/termsAndConditions.html"
    static let getDisplayPrice = "/getDisplayPrice"
}

struct Colors {
    static let accentColor = UIColor(named: "UserChatBubbleColor")!
    static let userChatBackgroundColor = UIColor(named: "UserChatBackgroundColor")!
    static let userChatBubbleColor = UIColor(named: "UserChatBubbleColor")!
    static let userChatTextColor = UIColor(named: "UserChatTextColor")!
    static let aiChatBubbleColor = UIColor(named: "AIChatBubbleColor")!
    static let aiChatTextColor = UIColor(named: "AIChatTextColor")!
}

struct FinishReasons {
    static let length = "length"
    static let stop = "stop"
}

enum ChatSender: Codable {
    case user
    case ai
}

