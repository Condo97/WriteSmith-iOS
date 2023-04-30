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
    static let userDefaultStoredAuthTokenKey = "authTokenKey"
    
    static let userDefaultHasFinishedIntro = "hasFinishedIntro"
    static let userDefaultStoredWeeklyDisplayPrice = "weeklyDisplayPrice"
    static let userDefaultStoredMonthlyDisplayPrice = "monthlyDisplayPrice"
    //    static let userDefaultStoredAnnualDisplayPrice = "annualDisplayPrice"
    static let userDefaultStoredFreeEssayCap = "freeEssayCap"
    static let userDefaultStoredShareURL = "shareURL"
    
    static let userDefaultStoredPremiumLastCheckDate = "premiumLastCheckDate"
    static let userDefaultStoredIsPremium = "storedIsPremium"
    
    static let userDefaultStoredGeneratedChatsRemaining = "generatedChatsRemaining"
    
    static let userDefaultStoredConversationToResume = "conversationToResume"
    
    static let userDefaultStoredShouldNotLoadFirstConversationChats = "shouldNotLoadFirstConversationChats"
    
    static let userDefaultNotFirstLaunch = "notFirstLaunch"
    static let userDefaultNotFirstCamera = "firstTimeCamera"
    
    
    //    static let shareURL = NSURL(string: "https://apps.apple.com/us/app/chit-chat-ai-chat-with-gpt/id1664039953")!
    
    static let reviewFrequency = 5
    static let adFrequency = 4
    
    static let freeTypingTimeInterval = 4.0/100
    static let premiumTypingTimeInterval = 2.0/100
    
    static let defaultTypingUpdateLetterCountFactor = 200
    static let introTypingUpdateLetterCountFactor = 100
    
    static let premiumCheckCooldownSeconds = 20.0
    
    static let defaultShareURL = "https://apps.apple.com/us/app/writesmith-ai-essay-helper/id1664039953"
    static let defaultFreeEssayCap = 4
    static let defaultWeeklyDisplayPrice = "5.99"
    static let defaultMonthlyDisplayPrice = "14.99"
    //    static let defaultAnnualDisplayPrice = "29.99"
    
    static let weeklyProductIdentifier = "chitchatultra"
    static let monthlyProductIdentifier = "ultramonthly"
    //    static let annualProductIdentifier = "chitchatultrayearly"
    
    static let mainStoryboardName = "Main"
    static let mainVCStoryboardName = "mainVC"
    static let ultraPurchaseViewStoryboardIdentifier = "ultraPurchaseView"
    
    static let primaryFontName = "Avenir-Book"
    static let primaryFontNameMedium = "Avenir-Medium"
    static let primaryFontNameBold = "Avenir-Heavy"
    static let primaryFontNameBlack = "Avenir-Black"
    static let primaryFontNameBlackOblique = "Avenir-BlackOblique"
    static let secondaryFontName = "Avenir-Heavy"
    
    static let copyFooterText = "Made on WriteSmith - AI Writing Author!"
    
    static let lengthFinishReasonAdditionalText = "...\n\nThis answer is too long for your plan. Please upgrade to Ultra for unlimited length."
    
    static let defaultTypingUpdateLetterCount = 1
    
    struct Migration {
        static let userDefaultStoredV3_5MigrationComplete = "storedV3_5MigrationComplete"
    }
    
    
    struct Chat {
        struct View {
            struct Table {
                struct Cell {
                    
                }
            }
        }
        
        struct Sender {
            static let user = "user"
            static let ai = "ai"
        }
    }
    
    struct Conversation {
        struct View {
            struct Table {
                struct Cell {
                    
                }
            }
        }
    }
    
    struct Essay {
        struct View {
            struct Table {
                struct Cell {
                    struct Prompt {
                        static let defaultEditedText = "Edited"
                    }
                }
            }
        }
        
        static let entityName = "Essay"
    }
    
    struct Settings {
        struct View {
            struct Table {
                struct Cell {
                    struct UltraPurchase {
                        static let giftImageName = Constants.ImageName.giftGif
                        static let defaultTitleText = "Tap to Claim 3 Days Free"
                        static let defaultTopLabelText = "WriteSmith Ultra hasn't been activated"
                    }
                    
                    struct Settings {
                        static let shareText = "Share App With Friends"
                        static let termsOfUseText = "Terms of Use"
                        static let privacyPolicyText = "Privacy Policy"
                        static let restorePurchasesText = "Restore Purchases"
                        
                        static let shareSystemImageName = "person.3"
                        static let termsOfUseSystemImageName = "newspaper"
                        static let privacyPolicySystemImageName = "paperclip"
                        static let restorePurchasesSystemImageName = "arrow.2.circlepath"
                    }
                }
            }
        }
    }
    
    struct ImageName {
        static let cameraButtonNotPressed = "cameraButtonNotPressed"
        static let cameraButtonPressed = "cameraButtonPressed"
        static let cameraButtonRedo = "cameraButtonRedo"
        
        static let chatBottomButtonTopSelected = "chatButtonTopSelected"
        static let chatBottomButtonTopNotSelected = "chatButtonTopNotSelected"
        static let chatBottomButtonBottom = "chatButtonBottom"
        
        static let giftGif = "giftGif"
        
        static let essayBottomButtonNotSelected = "writeBottomButtonNotSelected"
        static let essayBottomButtonSelected = "writeBottomButtonSelected"
        
        static let introScreenshot1 = "introScreenshot1"
        static let introScreenshot2 = "introScreenshot2"
        static let introScreenshot3 = "introScreenshot3"
        static let introScreenshot4 = "introScreenshot4"
        
        static let loadingDotsImageName = "loadingDots"
        
        static let shareBottomButtonNotSelected = "shareBottomButtonNotSelected"
        static let sparkleLightGif = "sparkleLightGif"
        static let sparkleDarkGif = "sparkleDarkGif"
        
        static let premiumBottomButtonNotSelected = "premiumBottomButtonNotSelected"
        
        static let ultraDark = "UltraDark"
        static let ultraLight = "UltraLight"
        static let ultraRectangle = "ultraRectangle"
    }
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
        static let chitChatServer = "https://chitchatserver.com/v1"
    #else
        static let chitChatServer = "https://chitchatserver.com/v1"
    #endif
    
    static let chitChatServerStaticFiles = "https://chitchatserver.com"
    
    static let registerUser = "/registerUser"
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
    static let limit = "limit"
    static let stop = "stop"
}

