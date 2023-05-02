//
//  ConversationViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import UIKit

class ConversationViewController: HeaderViewController {
    
    // Constants
    let conversationSection = 0
    
    let conversationTableViewManager: ConversationSourcedTableViewManager = ConversationSourcedTableViewManager()
    
    // Instance variables
    var shouldShowUltra = true
    
    var previousSelectedConversation: Conversation?
    
    // Initialization Variables
    var pushToConversation = false
    
    
    lazy var rootView: ManagedTableViewInView = {
        let view = RegistryHelper.instantiateAsView(nibName: Registry.Common.View.managedInsetGroupedTableViewIn, owner: self) as! ManagedTableViewInView
        view.tableView.backgroundColor = Colors.chatBackgroundColor
        return view
    }()
    
    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup Nibs */
        RegistryHelper.register(Registry.Conversation.View.Table.Cell.create, to: rootView.tableView)
        RegistryHelper.register(Registry.Conversation.View.Table.Cell.item, to: rootView.tableView)
        
        /* Setup TableView Manager */
        rootView.tableView.manager = conversationTableViewManager
        
        //TODO: Correct space for older chats
        
        /* If it should push, try and push ChatViewController with conversationResumingManager's Conversation, otherwise create a new Conversation and push */
        if pushToConversation {
            pushWith(conversation: (ConversationResumingManager.conversation ?? ConversationCDHelper.appendConversation())!, animated: false)
            pushToConversation = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /* Setup Cell Source */
        // Get all Conversations
        let allConversations = ConversationCDHelper.getAllConversations()
        
        // Set sources to date group sectioned conversation item sources
        conversationTableViewManager.sources = TableViewCellSourceFactory.makeSortedDateGroupSectionedConversationItemTableViewCellSourceArray(from: allConversations!, indicating: previousSelectedConversation, delegate: self)
        
        // Function to get ordered display string from date group range array
        func orderedDateGroupRangeToDisplayStringArray(dateGroupRangeArray: [DateGroupRange]) -> [String] {
            var titleStringArray: [String] = []
            for i in 0..<dateGroupRangeArray.count {
                titleStringArray.append(dateGroupRangeArray[i].displayString)
            }
            return titleStringArray
        }
        
        // Set ordered section header titles
        conversationTableViewManager.orderedSectionHeaderTitles = orderedDateGroupRangeToDisplayStringArray(dateGroupRangeArray: DateGroupRange.ordered)
        
        // Remove blank source arrays and headers
        var i = 0
        while (i < conversationTableViewManager.sources.count) {
            if conversationTableViewManager.sources[i].isEmpty {
                conversationTableViewManager.sources.remove(at: i)
                conversationTableViewManager.orderedSectionHeaderTitles?.remove(at: i)
            } else {
                i += 1
            }
        }
        
        // Insert Create source in array at section index 0
        conversationTableViewManager.sources.insert([ConversationCreateTableViewCellSource(didSelect: { tableView, indexPath in
            self.pushWith(conversation: ConversationCDHelper.appendConversation()!, animated: true)
        })], at: 0)
        
        // Insert blank section header title for the create section
        conversationTableViewManager.orderedSectionHeaderTitles?.insert("", at: 0)
        
        
        // Reload data on main thread
        DispatchQueue.main.async {
            self.rootView.tableView.reloadData()
        }
    }
    
    override func setLeftMenuBarItems() {
        super.setLeftMenuBarItems()
        
        // Remove first left bar button item if it is there
        if navigationItem.leftBarButtonItems!.count > 0 {
            navigationItem.leftBarButtonItems!.remove(at: 0)
        }
        
        //TODO: Swap this with the three lines, since the gear is shown on more views
        // Insert gear button with settingsPressed target as first left bar button item
        let settingsMenuBarButtonImage = UIImage(systemName: "gear")
        let settingsMenuBarButton = UIButton(type: .custom)
        settingsMenuBarButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 28.0)
        settingsMenuBarButton.tintColor = Colors.elementTextColor
        settingsMenuBarButton.setBackgroundImage(settingsMenuBarButtonImage, for: .normal)
        settingsMenuBarButton.addTarget(self, action: #selector(settingsPressed), for: .touchUpInside)
        let settingsMenuBarItem = UIBarButtonItem(customView: settingsMenuBarButton)
        
        navigationItem.leftBarButtonItems!.insert(settingsMenuBarItem, at: 0)
    }
    
    override func setRightMenuBarItems() {
        super.setRightMenuBarItems()
        
        // Create editing bar button item
        let editingBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonPressed))
        editingBarButtonItem.tintColor = Colors.elementTextColor
        editingBarButtonItem.setTitleTextAttributes([.font: UIFont(name: Constants.primaryFontNameMedium, size: 17.0)!], for: .normal)
        editingBarButtonItem.setTitleTextAttributes([.font: UIFont(name: Constants.primaryFontNameMedium, size: 17.0)!], for: .selected)
        
        // APpend edit button item to right menu bar items
        navigationItem.rightBarButtonItems?.append(editingBarButtonItem)
    }
    
    @objc func editButtonPressed(_ sender: UIBarButtonItem) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Toggle isEditing
        rootView.tableView.isEditing = !rootView.tableView.isEditing
        
        if rootView.tableView.isEditing {
            // If currently editing, show "Done"
            DispatchQueue.main.async {
                sender.title = "Done"
                sender.setTitleTextAttributes([.font: UIFont(name: Constants.primaryFontNameBold, size: 17.0)!], for: .normal)
                sender.setTitleTextAttributes([.font: UIFont(name: Constants.primaryFontNameBold, size: 17.0)!], for: .selected)
            }
        } else {
            // If not editing, show "Edit"
            DispatchQueue.main.async {
                sender.title = "Edit"
                sender.setTitleTextAttributes([.font: UIFont(name: Constants.primaryFontNameMedium, size: 17.0)!], for: .normal)
                sender.setTitleTextAttributes([.font: UIFont(name: Constants.primaryFontNameMedium, size: 17.0)!], for: .selected)
            }
        }
    }
    
    @objc func settingsPressed() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Push to settings
        navigationController?.pushViewController(SettingsPresentationSpecification().viewController, animated: true)
    }
    
    func pushWith(conversation: Conversation, animated: Bool) {
        // Create chatViewController instance
        let chatViewController = ChatViewController()
        
        // Set delegate
        chatViewController.delegate = self
        
        // Set with current conversation
        chatViewController.currentConversation = conversation
        
        // Set with shouldShowUltra, setting to false after
        chatViewController.shouldShowUltra = shouldShowUltra
        shouldShowUltra = false
        
        // Set with loadFirstConversationChats from userDefaults
        chatViewController.loadFirstConversationChats = !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredShouldNotLoadFirstConversationChats)
        UserDefaults.standard.set(true, forKey: Constants.userDefaultStoredShouldNotLoadFirstConversationChats)
        
        // Set previousSelectedConversation as current conversation
        previousSelectedConversation = conversation
        
        // Push to chatViewController
        navigationController?.pushViewController(chatViewController, animated: animated)
    }

}
