//
//  ConversationViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import CoreData
import UIKit

class ConversationViewController: HeaderViewController {
    
    // Constants
    let conversationSection = 0
    
//    let conversationTableViewManager: ConversationSourcedTableViewManager = ConversationSourcedTableViewManager()
    
    // Instance variables
    var shouldShowUltra = true
    
    var previousSelectedConversationObjectID: NSManagedObjectID?
    
    // Initialization Variables
    var pushToConversation = false
    
    lazy var fetchedResultsTableViewDataSource: TopViewFetchedResultsTableViewDataSource<Conversation>? = {
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Conversation.latestChatDate), ascending: false)
        ]
        
        return TopViewFetchedResultsTableViewDataSource(
            tableView: rootView.tableView,
            managedObjectContext: CDClient.mainManagedObjectContext,
            fetchRequest: fetchRequest,
            cacheName: nil,
            topViewCellReuseIdentifier: Registry.Conversation.View.Table.Cell.create.reuseID,
            topViewCellDelegate: self,
            editingDelegate: self,
            universalCellDelegate: nil,
            reuseIdentifier: {conversation, indexPath in
                return Registry.Conversation.View.Table.Cell.item.reuseID
            })
    }()
    
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
        
        /* Setup TableView Delegate and DataSource */
        rootView.tableView.delegate = self
        rootView.tableView.dataSource = fetchedResultsTableViewDataSource
//        rootView.tableView.manager = conversationTableViewManager
        
        //TODO: Correct space for older chats
        
        /* If it should push, try and push ChatViewController with conversationResumingManager's Conversation, otherwise create a new Conversation and push */
        if pushToConversation {
            Task {
                // Get conversationObjectIDToPushTo
                var conversationObjectIDToPushTo = await ConversationResumingManager.getConversationObjectID()
                
                // If conversationObjectIDToPushTo is invalid, append a conversation and set with the new conversation's objectID
                if await !ConversationCDHelper.isValidObject(conversationObjectID: conversationObjectIDToPushTo) {
                    do {
                        conversationObjectIDToPushTo = try await ConversationCDHelper.appendConversation()
                    } catch {
                        // TODO: Handle error
                        print("Could not create conversation in viewDidload in ConversationViewController... \(error)")
                    }
                }
                
                // Unwrap conversationToPushTo, otherwise do something with the error
                guard let conversationObjectIDToPushTo = conversationObjectIDToPushTo else {
                    // TODO: Handle error
                    print("Could not unwrap conversationToPushTo in viewDidLoad of ConversationViewController")
                    return
                }
                
                // Push to conversation and set pushToConversation to false
                pushWith(conversationObjectID: conversationObjectIDToPushTo, animated: false)
                pushToConversation = false
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        /* Setup Cell Source */
//        Task {
//            await setupCellSourcesAndHeaders()
//        }
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
    
//    func setupCellSourcesAndHeaders() async {
//        // Get all Conversations
//        let allConversations = await ConversationCDHelper.getAllConversations()
//
//        // Set sources to date group sectioned conversation item sources
//        conversationTableViewManager.sources = await TableViewCellSourceFactory.makeSortedDateGroupSectionedConversationItemTableViewCellSourceArray(from: allConversations!, indicating: previousSelectedConversation, delegate: self)
//
//        // Function to get ordered display string from date group range array
//        func orderedDateGroupRangeToDisplayStringArray(dateGroupRangeArray: [DateGroupRange]) -> [String] {
//            var titleStringArray: [String] = []
//            for i in 0..<dateGroupRangeArray.count {
//                titleStringArray.append(dateGroupRangeArray[i].displayString)
//            }
//            return titleStringArray
//        }
//
//        // Set ordered section header titles
//        conversationTableViewManager.orderedSectionHeaderTitles = orderedDateGroupRangeToDisplayStringArray(dateGroupRangeArray: DateGroupRange.ordered)
//
//        // Remove blank source arrays and headers
//        DispatchQueue.main.async {
//            var i = 0
//            while (i < self.conversationTableViewManager.sources.count) {
//                if self.conversationTableViewManager.sources[i].isEmpty {
//                    self.conversationTableViewManager.sources.remove(at: i)
//                    self.conversationTableViewManager.orderedSectionHeaderTitles?.remove(at: i)
//
//                    self.rootView.tableView.reloadData()
//                } else {
//                    i += 1
//                }
//            }
//        }
//
//        // Insert Create source in array at section index 0
//        conversationTableViewManager.sources.insert([ConversationCreateTableViewCellSource(didSelect: { tableView, indexPath in
//            Task {
//                do {
//                    // Append and unwrap newConversation
//                    guard let newConversation = try await ConversationCDHelper.appendConversation() else {
//                        // TODO: Handle error
//                        print("Could not append a conversation in viewWillAppear in ConversationViewController!")
//                        return
//                    }
//
//                    // Do light haptic
//                    HapticHelper.doLightHaptic()
//
//                    // Push with newConversation
//                    self.pushWith(conversation: newConversation, animated: true)
//                } catch {
//                    // TODO: Handle error
//                    print("Could not append conversation in viewWillAppear in ConversationViewController... \(error)")
//                }
//            }
//        })], at: 0)
//
//        // Insert blank section header title for the create section
//        conversationTableViewManager.orderedSectionHeaderTitles?.insert("", at: 0)
//
//
//        // Reload data on main thread
//        DispatchQueue.main.async {
//            self.rootView.tableView.reloadData()
//        }
//    }
    
    func pushWith(conversationObjectID: NSManagedObjectID, animated: Bool) {
        // Create chatViewController instance
        let chatViewController = ChatViewController()
        
        // Set delegate
        chatViewController.delegate = self
        
        // Set with current conversation
        chatViewController.currentConversationObjectID = conversationObjectID
        
        // Set with shouldShowUltra, setting to false after
        chatViewController.shouldShowUltra = shouldShowUltra
        shouldShowUltra = false
        
        // Set with loadFirstConversationChats from userDefaults
        chatViewController.loadFirstConversationChats = !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredShouldNotLoadFirstConversationChats)
        UserDefaults.standard.set(true, forKey: Constants.userDefaultStoredShouldNotLoadFirstConversationChats)
        
        // Set previousSelectedConversation as current conversation
        previousSelectedConversationObjectID = conversationObjectID
        
        // Push to chatViewController
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(chatViewController, animated: animated)
        }
    }

}
