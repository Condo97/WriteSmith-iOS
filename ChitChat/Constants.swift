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
    static let userDefaultStoredMonthlyDisplayPrice = "monthlyDisplayPrice"
//    static let userDefaultStoredAnnualDisplayPrice = "annualDisplayPrice"
    static let userDefaultStoredShareURL = "shareURL"
    
//    static let shareURL = NSURL(string: "https://apps.apple.com/us/app/chit-chat-ai-chat-with-gpt/id1664039953")!
    
    static let freeTypingTimeInterval = 5.0/100
    static let premiumTypingTimeInterval = 2.0/100
    
    static let defaultWeeklyDisplayPrice = "5.99"
    static let defaultMonthlyDisplayPrice = "14.99"
//    static let defaultAnnualDisplayPrice = "29.99"
    
    static let weeklyProductIdentifier = "chitchatultra"
    static let monthlyProductIdentifier = "ultramonthly"
//    static let annualProductIdentifier = "chitchatultrayearly"
    
    static let bodyWeeklyDisplayPriceName = "weeklyDisplayPrice"
    static let bodyMonthlyDisplayPriceName = "monthlyDisplayPrice"
    
    static let borderWidth = CGFloat(0.0)
    static let cornerRadius = 14.0
    
    static let primaryFontName = "Avenir-Book"
    static let primaryFontNameBold = "Avenir-Heavy"
    static let primaryFontNameBlack = "Avenir-Black"
    static let primaryFontNameBlackOblique = "Avenir-BlackOblique"
    static let secondaryFontName = "Avenir-Heavy"
    
    static let coreDataEssayEntityName = "Essay"
    static let coreDataEssayIDObjectName = "id"
    static let coreDataEssayPromptObjectName = "prompt"
    static let coreDataEssayEssayObjectName = "essay"
    static let coreDataEssayDateObjectName = "date"
    static let coreDataEssayUserEditedObjectName = "userEdited"
    
    static let copyFooterText = "Made on WriteSmith - AI Writing Author!"
    
    static let shareBottomButtonNotSelectedImageName = "shareBottomButtonNotSelected"
    static let premiumBottomButtonNotSelectedImageName = "premiumBottomButtonNotSelected"
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
    static let getShareURL = "/getShareURL"
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

