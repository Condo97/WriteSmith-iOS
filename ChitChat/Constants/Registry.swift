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
    struct Camera {
        struct View {
            static let camera = "CameraView"
        }
    }
    
    struct Chat {
        struct View {
            struct TableView {
                struct Cell {
                    static let user = XIB_ReuseID(
                        xibName: "UserChatTableViewCell",
                        reuseID: "userChatTableViewCell"
                    )
                    
                    static let ai = XIB_ReuseID(
                        xibName: "AIChatTableViewCell",
                        reuseID: "aiChatTableViewCell"
                    )
                    
                    static let loading = XIB_ReuseID(
                        xibName: "LoadingChatTableViewCell",
                        reuseID: "loadingChatTableViewCell"
                    )
                    
                    static let padding = XIB_ReuseID(
                        xibName: "PaddingChatTableViewCell",
                        reuseID: "paddingChatTableViewCell"
                    )
                }
            }
            
            static let chat = "ChatView"
        }
    }
    
    struct Common {
        struct View {
            struct TableView {
                struct Cell {
                    static let collection = XIB_ReuseID(
                        xibName: "CollectionTableViewCell",
                        reuseID: "collectionTableViewCell"
                    )
                    
                    static let imageText = XIB_ReuseID(
                        xibName: "ImageTextTableViewCell",
                        reuseID: "imageTextTableViewCell"
                    )
                    
                    static let label = XIB_ReuseID(
                        xibName: "LabelChatTableViewCell",
                        reuseID: "labelChatTableViewCell"
                    )
                }
            }
            
            static let tableViewIn = "ManagedTableViewInView"
        }
    }
    
    struct Essay {
        struct View {
            struct Table {
                struct Cell {
                    static let body = XIB_ReuseID(
                        xibName: "BodyEssayTableViewCell",
                        reuseID: "bodyEssayTableViewCell"
                    )
                    
                    static let entry = XIB_ReuseID(
                        xibName: "EntryEssayTableViewCell",
                        reuseID: "entryEssayTableViewCell"
                    )
                    
                    static let loading = XIB_ReuseID(
                        xibName: "LoadingEssayTableViewCell",
                        reuseID: "loadingEssayTableViewCell"
                    )
                    
                    static let premium = XIB_ReuseID(
                        xibName: "PremiumEssayTableViewCell",
                        reuseID: "premiumEssayTableViewCell"
                    )
                    
                    static let prompt = XIB_ReuseID(
                        xibName: "PromptEssayTableViewCell",
                        reuseID: "promptEssayTableViewCell"
                    )
                }
            }
            
            static let essay = "EssayView"
        }
    }
    
    struct Explore {
        struct View {
            struct CollectionView {
                struct Cell {
                    static let smallSquare = XIB_ReuseID(
                        xibName: "SmallSquareCollectionViewCell",
                        reuseID: "smallSquareCollectionViewCell"
                    )
                }
            }
        }
    }
    
    struct IntroInteractive {
        struct View {
            static let chat = "ChatIntroInteractiveView"
        }
    }
    
    struct Settings {
        struct View {
            struct TableView {
                struct Cell {
                    static let ultraPurchase = XIB_ReuseID(
                        xibName: "UltraPurchaseTableViewCell",
                        reuseID: "ultraPurchaseTableViewCell"
                    )
                }
            }
        }
    }
    
    struct Ultra {
        struct View {
            static let ultra = "UltraView"
        }
    }
}
