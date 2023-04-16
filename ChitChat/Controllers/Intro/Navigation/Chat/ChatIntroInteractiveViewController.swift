//
//  IntroInteractiveViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/21/23.
//

import Foundation
import UIKit

class ChatIntroInteractiveViewController: StackedViewController {
        
    let chatTableViewManager: SourcedTableViewManagerProtocol = SourcedTableViewManager()
    let choiceTableViewManager: SourcedTableViewManagerProtocol = SourcedTableViewManager()
    
    var rootView: ChatIntroInteractiveView!
    var headerLabelSources: [LabelTableViewCellSource] = []
    var chats: [ChatObject] = []
    var choices: [PreloadedResponseChatObject] = []
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        
        /* Setup Delegate and DataSource */
        rootView.chatTableView.manager = chatTableViewManager
        rootView.choiceTableView.manager = choiceTableViewManager
        
        /* Setup touchDelegate for TableViews */
        rootView.chatTableView.touchDelegate = self
        rootView.choiceTableView.touchDelegate = self
        
        /* Setup delegate for RootView */
        rootView.delegate = self
        
        /* Setup ChatCell Nibs TODO: Should this just be in ChatTableView? How can this be dynamic? */
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.user, to: rootView.chatTableView)
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.ai, to: rootView.chatTableView)
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.padding, to: rootView.chatTableView)
        RegistryHelper.register(Registry.Common.View.TableView.Cell.label, to: rootView.chatTableView)
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.loading, to: rootView.chatTableView)
        
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.user, to: rootView.choiceTableView)
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.ai, to: rootView.choiceTableView)
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.padding, to: rootView.choiceTableView)
        RegistryHelper.register(Registry.Common.View.TableView.Cell.label, to: rootView.choiceTableView)
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.loading, to: rootView.choiceTableView)
        
        
        /* Append Sources */
        
        // Has starting chats, just as chatObjects maybe, in an array for the chatTableView
        chatTableViewManager.sources.append(TableViewCellSourceFactory.makeChatTableViewCellSourceArray(fromChatObjectArray: chats))
        
        // Insert padding in first section of chatRowSources in chatTableViewManager
        chatTableViewManager.sources[0].insert(PaddingTableViewCellSource(padding: 40.0), at: 0)
        
        // Insert all objects in headerLabelSources startnig at the first row in the first section of chatRowSources in chatTableViewManager
        chatTableViewManager.sources[0].insert(contentsOf: headerLabelSources, at: 0)
        
        // Add padding in section 1 of chatRowSources in chatTableViewManager
        chatTableViewManager.sources.append([PaddingTableViewCellSource(padding: 40.0)])
        
        // Has choices, just as chatObjects too maybe, for the choiceTableView
        choiceTableViewManager.sources.append(TableViewCellSourceFactory.makeChatTableViewCellSourceArray(fromChatObjectArray: choices))
        
        // Insert label source as first row in the first section of choiceTableViewManager chatRowSources
        let labelSource = LabelTableViewCellSource(
            text: "Choose an Option:",
            font: UIFont(name: Constants.primaryFontNameBold, size: 24.0)!,
            color: Colors.elementBackgroundColor,
            heightConstraintConstant: nil,
            topSpaceConstraintConstant: 14.0,
            bottomSpaceConstraintConstant: 7.0
        )
        choiceTableViewManager.sources[0].insert(labelSource, at: 0)
        
        // Append padding source in first section of chatRowSources in choiceTableViewManager
        choiceTableViewManager.sources[0].append(PaddingTableViewCellSource(padding: 40.0))
        
        // TODO: - ChoiceTableViewManager to manage the selection and insertion and stuff
            // The choiceTableView has to have a delegate method for the selection index and rows need to bounce when tapped... Could this just be done in chatTableView or ChatTableViewManager? I mean there is already a tap thing right?
        
        /* Set NextButton, Choice TableView and its background to transparent */
        rootView.choiceTableView.alpha = 0.0
        rootView.choiceTableViewBackgroundView.alpha = 0.0
        rootView.nextButton.alpha = 0.0
        
        /* Setup Title Labels */
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Adjust height of choiceTableView using height constraint
        rootView.choiceTableViewHeightConstraint.constant = rootView.choiceTableView.contentSize.height
        
        UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
            self.rootView.choiceTableView.alpha = 1.0
            self.rootView.choiceTableViewBackgroundView.alpha = 1.0
        })
    }
    
    //MARK: Builder Functions
    
    class Builder {
        
        lazy var chatIntroInteractiveViewController: ChatIntroInteractiveViewController = ChatIntroInteractiveViewController()
        
        func set(rootViewNibName: String) -> Self {
            chatIntroInteractiveViewController.rootView = RegistryHelper.instantiateAsView(nibName: rootViewNibName, owner: chatIntroInteractiveViewController) as? ChatIntroInteractiveView
            return self
        }
        
        func add(headerLabelSource: LabelTableViewCellSource) -> Self {
            chatIntroInteractiveViewController.headerLabelSources.append(headerLabelSource)
            return self
        }
        
        func add(chat: ChatObject) -> Self {
            chatIntroInteractiveViewController.chats.append(chat)
            return self
        }
        
        func add(choice: PreloadedResponseChatObject) -> Self {
            chatIntroInteractiveViewController.choices.append(choice)
            return self
        }
        
        func build() -> ChatIntroInteractiveViewController {
            return chatIntroInteractiveViewController
        }
        
    }
}
