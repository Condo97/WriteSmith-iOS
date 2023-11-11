//
//  UIConstants.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import UIKit
import SwiftUI
import Foundation

struct Constants {
    
    struct Additional {
        static let coreDataModelName = "ChitChat"
    }
    
    struct FontName {
        
        private static let oblique = "Oblique"
        
        static let light = "avenir-light"
        static let lightOblique = light + oblique
        static let body = "avenir-book"
        static let bodyOblique = body + oblique
        static let medium = "avenir-medium"
        static let mediumOblique = medium + oblique
        static let heavy = "avenir-heavy"
        static let heavyOblique = heavy + oblique
        static let black = "avenir-black"
        static let blackOblique = black + oblique
        static let appname = "copperplate"
        
    }
    
    static let bottomButtonGradient = Color( "BottomButtonGradient")
    
    static let defaultChatID: Int64 = -1
    static let defaultConversationID: Int64 = -1
    
    
    //    static let shareURL = NSURL(string: "https://apps.apple.com/us/app/chit-chat-ai-chat-with-gpt/id1664039953")!
    
    static let reviewFrequency = 7
    static let adFrequency = 4
    static let premiumFrequency = 15
    
    static let freeTypingTimeInterval = 2.8/100
    static let premiumTypingTimeInterval = 2.0/100
    
    static let defaultTypingUpdateLetterCountFactor = 200
    static let introTypingUpdateLetterCountFactor = 100
    
    static let premiumCheckCooldownSeconds = 20.0
    
    static let defaultShareURL = URL(string: "https://apps.apple.com/us/app/writesmith-ai-essay-helper/id1664039953")!
    static let defaultFreeEssayCap = 3
    static let defaultWeeklyDisplayPrice = "5.99"
    static let defaultMonthlyDisplayPrice = "14.99"
    //    static let defaultAnnualDisplayPrice = "29.99"
    
    static let weeklyProductIdentifier = "chitchatultra"
    static let monthlyProductIdentifier = "ultramonthly"
    //    static let annualProductIdentifier = "chitchatultrayearly"
    
    static let mainStoryboardName = "Main"
    static let mainVCStoryboardName = "mainVC"
    static let ultraPurchaseViewStoryboardIdentifier = "ultraPurchaseView"
    
    static let copyFooterText = "Made on WriteSmith - AI Writing Author!"
    
    static let lengthFinishReasonAdditionalText = "...\n\nThis answer is too long for your plan. Please upgrade to Ultra for unlimited length."
    
    static let defaultTypingUpdateLetterCount = 1
    
    struct Migration {
        static let userDefaultStoredLatestVersionMigrationComplete = "latestVersionMigrationComplete"
        
        static let userDefaultStoredV3_5MigrationComplete = "storedV3_5MigrationComplete"
        static let userDefaultStoredV4MigrationComplete = "v4MigrationComplete"
        static let userDefaultStoredV4_2MigrationComplete = "v4_2MigrationComplete"
    }
    
    
    struct Chat {
        struct View {
            struct Table {
                struct Cell {
                    
                }
                
                static let freeFooterHeight = 240.0
                static let ultraFooterHeight = 140.0
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
        struct BottomBarImages {
            static let chatBottomButtonTopSelected = "chatButtonTopSelected"
            static let chatBottomButtonTopNotSelected = "chatButtonTopNotSelected"
            static let chatBottomButtonBottom = "chatButtonBottom"
            
            static let createBottomButton = "createBottomButton"
            static let createBottomButtonSelected = "createBottomButtonSelected"
            
            static let essayBottomButtonNotSelected = "writeBottomButtonNotSelected"
            static let essayBottomButtonSelected = "writeBottomButtonSelected"
            
            static let premiumBottomButtonNotSelected = "premiumBottomButtonNotSelected"
            
            static let shareBottomButtonNotSelected = "shareBottomButtonNotSelected"
            
//            static let sparkleDarkBottomBarBackgroundColor = "sparkleDarkBottomBarBackgroundColor"
//            static let sparkleDarkElementTextColor = "sparkleDarkElementTextColor"
//            static let sparkleLightBottomBarBackgroundColor = "sparkleLightBottomBarBackgroundColor"
//            static let sparkleLightElementTextColor = "sparkleLightElementTextColor"
            
            static let sparkleDarkGif = "sparkleDarkGif"
            static let sparkleLightGif = "sparkleLightGif"
        }
        
        struct ItemSourceImages {
            static let instagram = "Instagram"
            static let linkedIn = "LinkedIn"
            static let tikTok = "TikTok"
            static let twitter = "Twitter"
        }
        
        struct Ultra {
            static let ultraDark = "UltraDark"
            static let ultraLight = "UltraLight"
            static let ultraRectangle = "ultraRectangle"
        }
        
        static let aiChatImage = "aiChatImage"
        
        static let cameraButtonNotPressed = "cameraButtonNotPressed"
        static let cameraButtonPressed = "cameraButtonPressed"
        static let cameraButtonRedo = "cameraButtonRedo"
        
        static let faceImageName = "face_background"
        static let faceTabBarBackgroundImageName = "tabBarFaceBackground"
        static let faceTabBarBackgroundRingImageName = "tabBarFaceBackgroundRing"
        
        static let giftGif = "giftGif"
        
        static let gptModelGifElementLight = "GPTModelGifElementBackgroundColorLight"
        static let gptModelGifElementDark = "GPTModelGifElementBackgroundColorDark"
        
        static let introScreenshot1 = "introScreenshot1"
        static let introScreenshot2 = "introScreenshot2"
        static let introScreenshot3 = "introScreenshot3"
        static let introScreenshot4 = "introScreenshot4"
        
        static let loadingDotsImageName = "loadingDots"
        
        static let logo = "logoImage"
        
        static let share = "shareImage"
        
        static let sparkleLightGif = "sparkleLightGif"
        static let sparkleDarkGif = "sparkleDarkGif"
    }
    
    struct UserDefaults {
        static let appLaunchAlert = "appLaunchAlert"
        
        static let chatStorageUserDefaultKey = "chatStorageUserDefaultKey"
        static let pastChatStorageUserDefaultKey = "pastChatStorageUserDefaultKey"
        
        static let hapticsDisabled = "hapticsDisabled"
        
        static let panelGroupsJSON = "panelGroupsJSON"
        
        static let userDefaultStoredAuthTokenKey = "authTokenKey"
        
        static let userDefaultHasFinishedIntro = "hasFinishedIntro"
        static let userDefaultStoredWeeklyDisplayPrice = "weeklyDisplayPrice"
        static let userDefaultStoredMonthlyDisplayPrice = "monthlyDisplayPrice"
        //    static let userDefaultStoredAnnualDisplayPrice = "annualDisplayPrice"
        static let userDefaultStoredFreeEssayCap = "freeEssayCap"
        static let userDefaultStoredShareURL = "shareURL"
        
        
        static let userDefaultStoredPremiumLastCheckDate = "premiumLastCheckDate"
        static let userDefaultStoredIsPremium = "storedIsPremium"
        
        static let userDefaultStoredChatGPTModel = "chatGPTModel"
        
        static let userDefaultStoredGeneratedChatsRemaining = "generatedChatsRemaining"
        
        static let userDefaultStoredConversationToResume = "conversationToResume"
        
        static let userDefaultStoredShouldNotLoadFirstConversationChats = "shouldNotLoadFirstConversationChats"
        
        static let userDefaultNotFirstLaunch = "notFirstLaunch"
        static let userDefaultNotFirstCamera = "firstTimeCamera"
        
        static let userDefaultStoredSettingReduceMotion = "settingReduceMotion"
    }
}

struct UIConstants {
    static let borderWidth = CGFloat(0.0)
    static let cornerRadius = 14.0
    static let outerCornerRadius = 20.0
    
    static let defaultDotSpeed = 0.4
    static let defaultDotMinSizeDivisor = 4.0
    
    static let defaultChatTableViewHeaderHeight = 180.0
    static let premiumChatTableViewHeaderHeight = 120.0
    
    static let defaultChatTableViewFooterHeight = 64.0
    static let premiumChatTableViewFooterHeight = 40.0
    
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
    
    static let deleteChat = "/deleteChat"
    static let getChat = "/getChat"
    static let getIAPStuff = "/getIAPStuff"
    static let getIsPremium = "/getIsPremium"
    static let getRemaining = "/getRemaining"
    static let registerTransaction = "/registerTransaction"
    static let registerUser = "/registerUser"
    static let validateSaveUpdateReceipt = "/validateAndUpdateReceipt"
//    static let getGenerateImage = "/getImageUrlFromGenerateUrl"
    
    static let getImportantConstants = "/getImportantConstants"
    static let privacyPolicy = "/privacyPolicy.html"
    static let termsAndConditions = "/termsAndConditions.html"
}

struct HTTPSResponseConstants {
    static let shareURL = "shareURL"
    static let weeklyDisplayPrice = "weeklyDisplayPrice"
    static let monthlyDisplayPrice = "monthlyDisplayPrice"
    static let freeEssayCap = "freeEssayCap"
}

struct WebSocketConstants {
    #if DEBUG
        static let chitChatWebSocketServer = "wss://chitchatserver.com/v1"
    #else
        static let chitChatWebSocketServer = "wss://chitchatserver.com/v1"
    #endif
    
    static let getChatStream = "/getChatStream"
}

struct Colors {
//    static let accentColor = Color("UserChatBubbleColor")
    static let alertTintColor = Color(uiColor: UIColor(named: "ElementBackgroundColor")!.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)))
    static let background = Color("ChatBackgroundColor")
    static let buttonBackground = Color("UserChatBubbleColor")
    static let foreground = Color("ForegroundColor")
    static let userChatBubbleColor = Color("UserChatBubbleColor")
    static let userChatTextColor = Color("UserChatTextColor")
    static let aiChatBubbleColor = Color("AIChatBubbleColor")
    static let aiChatTextColor = Color("AIChatTextColor")
    static let elementBackgroundColor = Color( "ElementBackgroundColor")
    static let elementTextColor = Color( "ElementTextColor")
    static let text = Color("Text")
    static let textOnBackgroundColor = Color( "TextOnBackgroundColor")
    static let topBarBackgroundColor = Color( "TopBarBackgroundColor")
    static let bottomBarBackgroundColor = Color( "BottomBarBackgroundColor")
//    static let alertTintColor = userChatBubbleColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
}
