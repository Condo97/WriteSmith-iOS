//
//  Registry.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/23/23.
//

import Foundation

/***
 IDs and Names to associate objects with strings
 */
struct Registry {
    struct View {
        struct IntroInteractiveView {
            static let chat = "ChatIntroInteractiveView"
        }
        
        struct TableView {
            struct Chat {
                struct Cells {
                    static let user = XIB_ReuseID(
                        xibName: "UserChatCell",
                        reuseID: "userChatCell"
                    )
                    
                    static let ai = XIB_ReuseID(
                        xibName: "AIChatCell",
                        reuseID: "aiChatCell"
                    )
                    
                    static let loading = XIB_ReuseID(
                        xibName: "LoadingChatCell",
                        reuseID: "loadingChatCell"
                    )
                    
                    static let padding = XIB_ReuseID(
                        xibName: "PaddingChatCell",
                        reuseID: "paddingChatCell"
                    )
                }
            }
            
            struct Essay {
                struct Cells {
                    static let body = XIB_ReuseID(
                        xibName: "BodyEssayCell",
                        reuseID: "bodyEssayCell"
                    )
                    
                    static let entry = XIB_ReuseID(
                        xibName: "EntryEssayCel",
                        reuseID: "entryEssayCell"
                    )
                    
                    static let loading = XIB_ReuseID(
                        xibName: "LoadingEssayCell",
                        reuseID: "loadingEssayCell"
                    )
                    
                    static let premium = XIB_ReuseID(
                        xibName: "PremiumEssayCell",
                        reuseID: "premiumEssayCell"
                    )
                    
                    static let prompt = XIB_ReuseID(
                        xibName: "PromptEssayCell",
                        reuseID: "promptEssayCell"
                    )
                }
            }
            
            struct Simple {
                struct Cells {
                    static let label = XIB_ReuseID(
                        xibName: "LabelChatCell",
                        reuseID: "labelChatCell"
                    )
                }
            }
        }
    }
}
