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
            struct Collection {
                struct Cell {
                    static let roundedViewLabelCollectionViewCell = XIB_ReuseID(
                        xibName: "RoundedViewLabelCollectionViewCell",
                        reuseID: "roundedViewLabelCollectionViewCell"
                    )
                }
            }
            
            struct Table {
                struct Cell {
                    static let managedCollectionView = XIB_ReuseID(
                        xibName: "ManagedCollectionViewTableViewCell",
                        reuseID: "managedCollectionViewTableViewCell"
                    )
                    
                    static let imageText = XIB_ReuseID(
                        xibName: "ImageTextTableViewCell",
                        reuseID: "imageTextTableViewCell"
                    )
                    
                    static let label = XIB_ReuseID(
                        xibName: "LabelChatTableViewCell",
                        reuseID: "labelChatTableViewCell"
                    )
                    
                    static let textView = XIB_ReuseID(
                        xibName: "TextViewTableViewCell",
                        reuseID: "textViewTableViewCell"
                    )
                }
            }
            
            static let managedTableViewIn = "ManagedTableViewInView"
            static let managedInsetGroupedTableViewIn = "ManagedInsetGroupedTableViewInView"
        }
        
        static let ultraNavigationItemView = "UltraNavigationItemView"
    }
    
    struct Conversation {
        struct View {
            struct Table {
                struct Cell {
                    static let create = XIB_ReuseID(
                        xibName: "ConversationCreateTableViewCell",
                        reuseID: "conversationCreateTableViewCell"
                    )
                    
                    static let item = XIB_ReuseID(
                        xibName: "ConversationItemTableViewCell",
                        reuseID: "conversationItemTableViewCell"
                    )
                }
            }
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
            struct Collection {
                struct Cell {
                    static let item = XIB_ReuseID(
                        xibName: "ItemExploreCollectionViewCell",
                        reuseID: "itemExploreCollectionViewCell"
                    )
                }
            }
            
            struct Table {
                struct Cell {
                    struct Item {
                        static let component = XIB_ReuseID(
                            xibName: "ComponentItemExploreTableViewCell",
                            reuseID: "componentItemExploreTableViewCell"
                        )
                        
                        static let header = XIB_ReuseID(
                            xibName: "HeaderItemExploreTableViewCell",
                            reuseID: "headerItemExploreTableViewCell"
                        )
                    }
                    
                    static let collection = XIB_ReuseID(
                        xibName: "ExploreCollectionTableViewCell",
                        reuseID: "exploreCollectionTableViewCell"
                    )
                    
                    static let creation = XIB_ReuseID(
                        xibName: "CreationExploreTableViewCell",
                        reuseID: "creationExploreTableViewCell"
                    )
                }
            }
            
            static let itemExplore = "ItemExploreView"
            static let explore = "ExploreView"
        }
    }
    
    struct Intro {
        struct View {
            static let intro = "IntroView"
        }
    }
    
    struct Settings {
        struct View {
            struct Table {
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
