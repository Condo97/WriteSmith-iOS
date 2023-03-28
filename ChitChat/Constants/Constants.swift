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
    static let userDefaultStoredFreeEssayCap = "freeEssayCap"
    static let userDefaultStoredShareURL = "shareURL"
    
    static let userDefaultFirstTimeCamera = "firstTimeCamera"
    
//    static let shareURL = NSURL(string: "https://apps.apple.com/us/app/chit-chat-ai-chat-with-gpt/id1664039953")!
    
    static let reviewFrequency = 5
    static let adFrequency = 4
    
    static let freeTypingTimeInterval = 4.0/100
    static let premiumTypingTimeInterval = 2.0/100
    
    static let defaultTypingUpdateLetterCountFactor = 200
    static let introTypingUpdateLetterCountFactor = 100
    
    static let defaultWeeklyDisplayPrice = "5.99"
    static let defaultMonthlyDisplayPrice = "14.99"
//    static let defaultAnnualDisplayPrice = "29.99"
    
    static let weeklyProductIdentifier = "chitchatultra"
    static let monthlyProductIdentifier = "ultramonthly"
//    static let annualProductIdentifier = "chitchatultrayearly"
    
    static let mainStoryboardName = "Main"
    static let ultraPurchaseViewStoryboardIdentifier = "ultraPurchaseView"
    
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
    
    
    static let cameraButtonNotPressedImageName = "cameraButtonNotPressed"
    static let cameraButtonPressedImageName = "cameraButtonPressed"
    static let cameraButtonRedo = "cameraButtonRedo"
    
    static let chatBottomButtonTopSelectedImageName = "chatButtonTopSelected"
    static let chatBottomButtonTopNotSelectedImageName = "chatButtonTopNotSelected"
    static let chatBottomButtonBottomImageName = "chatButtonBottom"
    
    static let defaultTypingUpdateLetterCount = 1
    
    static let loadingDotsImageName = "loadingDots"
    
    static let shareBottomButtonNotSelectedImageName = "shareBottomButtonNotSelected"
    static let premiumBottomButtonNotSelectedImageName = "premiumBottomButtonNotSelected"
    
    static let ultraLightImageName = "UltraLight"
    static let ultraDarkImageName = "UltraDark"
}

struct UIConstants {
    static let borderWidth = CGFloat(0.0)
    static let cornerRadius = 14.0
    
    static let defaultDotSpeed = 0.4
    static let defaultDotMinSizeDivisor = 4.0
    
    static let defaultPaddingTableViewCellSourceHeight = 240.0
    static let premiumPaddingTableViewCellSourceHeight = 120.0
    
    static let defaultLabelTableViewCellSourceFontSize = 24.0
    static let defaultLabelTableViewCellSourceConstraintConstant = 0.0
    static let defaultLabelTableViewCellSourceColor = Colors.elementTextColor
}

struct HTTPSConstants {
    #if DEBUG
        static let chitChatServer = "https://chitchatserver.com"
    #else
        static let chitChatServer = "https://chitchatserver.com/v1"
    #endif
    
    static let registerUesr = "/registerUser"
    static let getRemaining = "/getRemaining"
    static let getChat = "/getChat"
    static let validateSaveUpdateReceipt = "/validateAndUpdateReceipt"
//    static let getGenerateImage = "/getImageUrlFromGenerateUrl"
    static let getIAPStuff = "/getIAPStuff"
    static let privacyPolicy = "/privacyPolicy.html"
    static let termsAndConditions = "/termsAndConditions.html"
    static let getImportantConstants = "/getImportantConstants"
}

struct HTTPSResponseConstants {
    static let shareURL = "shareURL"
    static let weeklyDisplayPrice = "weeklyDisplayPrice"
    static let monthlyDisplayPrice = "monthlyDisplayPrice"
    static let freeEssayCap = "freeEssayCap"
}

struct Colors {
    static let accentColor = UIColor(named: "UserChatBubbleColor")!
    static let chatBackgroundColor = UIColor(named: "ChatBackgroundColor")!
    static let userChatBubbleColor = UIColor(named: "UserChatBubbleColor")!
    static let userChatTextColor = UIColor(named: "UserChatTextColor")!
    static let aiChatBubbleColor = UIColor(named: "AIChatBubbleColor")!
    static let aiChatTextColor = UIColor(named: "AIChatTextColor")!
    static let elementBackgroundColor = UIColor(named: "ElementBackgroundColor")!
    static let elementTextColor = UIColor(named: "ElementTextColor")!
    static let headerTextColor = UIColor(named: "HeaderTextColor")!
    static let topBarBackgroundColor = UIColor(named: "TopBarBackgroundColor")!
    static let bottomBarBackgroundColor = UIColor(named: "BottomBarBackgroundColor")!
}

struct FinishReasons {
    static let length = "length"
    static let stop = "stop"
}

enum ChatSender: Codable {
    case user
    case ai
}

