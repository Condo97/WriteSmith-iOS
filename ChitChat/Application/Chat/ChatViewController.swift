//
//  MainViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import CoreData
import GoogleMobileAds
import StoreKit
import UIKit

protocol ChatViewControllerDelegate {
    func popAndPushToNewConversation()
}

class ChatViewController: HeaderViewController {
    
    // Constants
    let CHAT_SECTION = 0
    
    let promoViewHeightConstraintConstant = 50.0
    
//    let sourcedTableViewManager: SourcedTableViewManagerProtocol = {
//        var sbhstvm = SmallBlankHeaderSourcedTableViewManager()
//        sbhstvm.blankHeaderHeight = 40.0
//        return sbhstvm
//    }()
    
    // Instance variables
    var originalBottomViewBottomAlignmentConstraintConstant: CGFloat = 0.0
    var prevContentOffsetFactor: CGFloat?
    var keyboardShowing = false
    
    var shouldScrollOnFirstAppear = true
    var firstChat = true
    var isProcessingChat = false
    var isLongPressForShare = false
    
    var remaining = -1
    
    var cameraButtonHeightConstraintSet = false
    
    var timeInterval = Constants.freeTypingTimeInterval
    
    var gptModelNameAnimationTimer: Timer?
    var defaultGPTModelNameAnimationDuration: Double = 4.0
    var gptModelNameAnimationPlayedCount: Int = 0
    
    var interstitial: GADInterstitialAd?
    var banner: GADBannerView!
    var failedToLoadInterstitial = false
    
    // Initialization variables
    var currentConversationObjectID: NSManagedObjectID? {
        didSet {
            if let currentConversationObjectID = currentConversationObjectID {
                ConversationResumingManager.setConversation(conversationObjectID: currentConversationObjectID)
            }
        }
    }
    
    var shouldShowUltra = false
    var loadFirstConversationChats = false
    var delegate: ChatViewControllerDelegate?
    
    lazy var chatTableViewDelegate: ChatTableViewDelegate = {
        ChatTableViewDelegate()
    }()
    
    lazy var fetchedResultsTableViewDataSource: ChatTableViewDataSource<Chat>? = {
        guard let currentConversationObjectID = currentConversationObjectID else {
            // Must have currentConversation.. TODO: Handle errors!
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Chat> = Chat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), currentConversationObjectID)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Chat.date), ascending: true)
        ]
        
        return ChatTableViewDataSource<Chat>(
            tableView: rootView.tableView,
            managedObjectContext: CDClient.mainManagedObjectContext,
            fetchRequest: fetchRequest,
            cacheName: nil,
            pulsatingDotsLoadingCellReuseIdentifier: Registry.Chat.View.Table.Cell.loading.reuseID,
            editingDelegate: self,
            universalCellDelegate: nil,
            reuseIdentifier: {chat, indexPath in
                if chat.sender == Constants.Chat.Sender.user {
                    return Registry.Chat.View.Table.Cell.user.reuseID
                } else {
                    return Registry.Chat.View.Table.Cell.ai.reuseID
                }
            })
    }()
    
    lazy var rootView: ChatView = {
        let view = RegistryHelper.instantiateAsView(nibName: Registry.Chat.View.chat, owner: self) as! ChatView
        view.delegate = self
        view.inputPlaceholder = "Tap to start chatting..."
        return view
    }()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup Delegates */
//        sourcedTableViewManager.delegate = self
        
        rootView.inputTextView.delegate = self
        rootView.tableView.delegate = chatTableViewDelegate
        rootView.tableView.dataSource = fetchedResultsTableViewDataSource
        
        /* Set TableView touchDelegate */
        rootView.tableView.touchDelegate = self
        
        /* Register Nibs TODO: Should this just be in ChatTableView? How can this be dynamic? */
        RegistryHelper.register(Registry.Chat.View.Table.Cell.user, to: rootView.tableView)
        RegistryHelper.register(Registry.Chat.View.Table.Cell.ai, to: rootView.tableView)
        RegistryHelper.register(Registry.Chat.View.Table.Cell.padding, to: rootView.tableView)
        RegistryHelper.register(Registry.Chat.View.Table.Cell.loading, to: rootView.tableView)
        
        /* Setup UI Stuff */
        // Set tableView estimated row height and row height to automatic dimension
        rootView.tableView.estimatedRowHeight = 44.0
        rootView.tableView.rowHeight = UITableView.automaticDimension
        
        // Set submitButton to be enabled and cameraButton to be not enabled
        rootView.submitButton.isEnabled = false
        rootView.cameraButton.isEnabled = true
        
        // Set the navigationController view backgroundColor so when the keyboard shows there won't be a black space during the animation due to the different speeds of keyboard and view animation
        navigationController!.view.backgroundColor = Colors.chatBackgroundColor
        
        // Setup "placeholder" for TextView
        rootView.inputTextViewSetToPlaceholder()
        
        // Setup Keyboard Stuff
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Dismiss Keyboard Gesture Recognizer
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardSelector))
        dismissKeyboardGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
        
        // Tap on Remaining View to upgrade gesture recognizer
        rootView.remainingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upgradeSelector)))
        
        // Long press for message share sheet
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnTableView))
        longPressGestureRecognizer.cancelsTouchesInView = false
        longPressGestureRecognizer.minimumPressDuration = 0.4
        rootView.tableView.addGestureRecognizer(longPressGestureRecognizer)
        
        // Set remaining view to transparent before it loads
        rootView.remainingView.alpha = 0.0
        
        // Set gpt model tap gesture recognizer
        let gptModelNameViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressGPTModelNameButton))
        rootView.gptModelView.addGestureRecognizer(gptModelNameViewTapGestureRecognizer)
        
        // Set gpt model text and image
        setGPTViewElements()
        
        /* Setup ad view and ads */
        interstitial?.fullScreenContentDelegate = self
        
        rootView.adView.alpha = 0.0
        rootView.adViewHeightConstraint.constant = 0.0
        
        banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = Private.bannerID
        banner.rootViewController = self
        banner.delegate = self
        
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            banner.load(GADRequest())
            loadGAD()
        }
        
//        /* Setup Cell Source */
//        Task {
//            await setCellSource()
//
//            LaunchControl.dismiss(animated: true)
//        }
        
        /* Dismiss LaunchControl */
        Task {
            LaunchControl.dismiss(animated: true)
        }
        
        // Set up default tiered padding source at index 1 in spacerSection
        //        sourcedTableViewManager.sources.insert([TieredPaddingTableViewCellSource()], at: spacerSection)
        
        // If first time launch, set shouldShowUltra to false
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultNotFirstLaunch) {
            shouldShowUltra = false
            UserDefaults.standard.set(true, forKey: Constants.userDefaultNotFirstLaunch)
        }
        
        // Initial updates
        updateInputTextViewSize(textView: rootView.inputTextView)
        
        // Scroll to bottom if shouldScrollOnFirstAppear
        if shouldScrollOnFirstAppear {
            DispatchQueue.main.async {
                self.rootView.tableView.scrollToBottomRow(animated: false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update premium items with stored status
        //updatePremium(isPremium: PremiumHelper.get())
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set the camera button constraints
        if !cameraButtonHeightConstraintSet && rootView.isBlankWithPlaceholder {
            rootView.cameraButtonHeightConstraint.constant = rootView.inputBackgroundView.frame.height
            
            cameraButtonHeightConstraintSet = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set origin for keyboard
        originalBottomViewBottomAlignmentConstraintConstant = rootView.bottomViewBottomAlignmentConstraint.constant
        
        // Show Ultra Purchase on launch if not premium
        if shouldShowUltra && !PremiumHelper.get() {
            shouldShowUltra = false
//            goToUltraPurchase()
        }
        
        // Show first conversation chats or add chat from first chat generator TODO: This all should be done somewhere else
        if loadFirstConversationChats {
            Task {
                do {
                    try await showFirstConversationChats()
                } catch {
                    // TODO: Handle error
                    print("Error showing first conversation chats in viewDidAppear in ChatViewController... \(error)")
                }
            }
            
            // Set to false to ensure it doesn't load again if the view appears multiple times
            loadFirstConversationChats = false
        } else {
            // Only add random first chat if there are no chat rows
            DispatchQueue.main.async {
                if var currentConversationObjectID = self.currentConversationObjectID {
                    if self.rootView.tableView.numberOfRows(inSection: self.CHAT_SECTION) == 0 {
                        Task {
                            do {
                                try await self.addChat(message: FirstChatGenerator.getRandomFirstChat(), sender: Constants.Chat.Sender.ai, forceAnimation: true)
//                                        self.animateChatRowIn(view: view)
//                                self.animateLastRowIn()
                            } catch {
                                // TODO: Handle error
                                print("Error adding chat in viewDidAppear in ChatViewController... \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func updatePremium(isPremium: Bool) {
        super.updatePremium(isPremium: isPremium)
        
        // Do all updates on main queue
        DispatchQueue.main.async {
            // Set bottom purchase buttons
            self.rootView.remainingView.isHidden = isPremium
            self.rootView.remainingShadowView.isHidden = isPremium
            self.rootView.promoView.isHidden = isPremium
            self.rootView.promoShadowView.isHidden = isPremium
            
            // Set promoViewHeightConstraint
            self.rootView.promoViewHeightConstraint.constant = isPremium ? 0.0 : self.promoViewHeightConstraintConstant
            
//            // Set tableView manager footer height
//            if let stvm = self.sourcedTableViewManager as? SourcedTableViewManager {
//                self.rootView.tableView.beginUpdates()
//                stvm.lastSectionFooterHeightAddition = isPremium ? Constants.Chat.View.Table.ultraFooterHeight : Constants.Chat.View.Table.freeFooterHeight
//                self.rootView.tableView.endUpdates()
//            }
            
            // Set adView visibility if premium
            if isPremium {
                self.rootView.adView.alpha = 0.0
                self.rootView.adViewHeightConstraint.constant = 0.0
                self.rootView.adShadowView.isHidden = true
            }
            
            // Set GPT View Elements
            self.setGPTViewElements()
        }
    }
    
    override func updateGeneratedChatsRemaining(remaining: Int) {
        super.updateGeneratedChatsRemaining(remaining: remaining)
        
        // Set instance remaining
        self.remaining = remaining
        
        // Set chatsRemainingText on main queue
        DispatchQueue.main.async {
            self.rootView.chatsRemainingText.text = "You have \(remaining < 0 ? 0 : remaining) chat\(remaining == 1 ? "" : "s") remaining today..."
            
            // If the remainingView is transparent, show it now that generated chats remaining has loaded
            if self.rootView.remainingView.alpha == 0.0 {
                UIView.animate(withDuration: 0.4, animations: {
                    self.rootView.remainingView.alpha = 1.0
                })
            }
        }
    }
    
    override func setRightMenuBarItems() {
        super.setRightMenuBarItems()
        
        // Add plus to right bar button items on right
        let plusButtonImage = UIImage(systemName: "plus.bubble")
        let plusButton = UIButton(type: .custom)
        plusButton.frame = CGRect(x: 0, y: 0, width: 30, height: 26)
        plusButton.tintColor = Colors.elementTextColor
        plusButton.setBackgroundImage(plusButtonImage, for: .normal)
        plusButton.addTarget(self, action: #selector(addConversationPressed), for: .touchUpInside)
        let plusBarButtonItem = UIBarButtonItem(customView: plusButton)
        
        // Append as last rightBarButtonItem
        navigationItem.rightBarButtonItems?.append(plusBarButtonItem)
    }
    
    override func openMenu() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Pop view controller to go to Conversation view
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setGPTViewElements()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        // Set keyboardShowing to true immediately
        keyboardShowing = true
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Get additional bottom offset if the user is not premium
            let additionalBottomOffset = PremiumHelper.get() ? 0.0 : 14.0
            
            // Move the rootView bottomViewBottomAlignmentConstraint and tableView contentOffset up with keyboard
            if self.rootView.bottomViewBottomAlignmentConstraint.constant == self.originalBottomViewBottomAlignmentConstraintConstant {
                //TODO: - In the previous version, the -tabBarController.tabBar.frame.size.height wasn't necessary, but now it is otherwise a black box the size of the tabBar will show up
                if let tabBarController = UIApplication.shared.topmostViewController()?.tabBarController {
                    // Calculate offset and set it to prevContentOffsetFactor
                    let offset = keyboardSize.height - tabBarController.tabBar.frame.size.height - self.originalBottomViewBottomAlignmentConstraintConstant - (self.rootView.bottomView.bounds.height - self.rootView.promoView.frame.maxY) + additionalBottomOffset
                    self.prevContentOffsetFactor = offset
                    
                    // Add offset to bottomViewBottomAlignmentConstraint constant and tableView y contentOffset, and call layoutIfNeeded to animate
                    self.rootView.bottomViewBottomAlignmentConstraint.constant += offset
                    self.rootView.tableView.contentOffset.y += offset
                    self.rootView.layoutIfNeeded()
                } else {
                    view.endEditing(true)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // Set keyboardShowing to false when animation is finished
        if let userInfo = notification.userInfo, let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            DispatchQueue.main.asyncAfter(deadline: .now() + keyboardAnimationDuration) {
                self.keyboardShowing = false
            }
        }
        
        // Move the bottomViewBottomAlignmentConstraint constant back to its original value, and move tableView y contentOffset down by prevContentOffsetFactor if it can be unwrapped
        if self.rootView.bottomViewBottomAlignmentConstraint.constant != self.originalBottomViewBottomAlignmentConstraintConstant {
            self.rootView.bottomViewBottomAlignmentConstraint.constant = self.originalBottomViewBottomAlignmentConstraintConstant
            if let prevContentOffsetFactor = self.prevContentOffsetFactor {
                self.rootView.tableView.contentOffset.y -= prevContentOffsetFactor
            }
            self.rootView.layoutIfNeeded()
        }
    }
    
    @objc func dismissKeyboardSelector(sender: UITapGestureRecognizer) {
        // Dissmisses keyboard if anything on the screen is tapped besides submitButton
        if rootView.hitTest(sender.location(in: self.view), with: nil) == rootView.submitButton  {
            return
        }
        
        // Dismiss keyboard
        dismissKeyboard()
    }
    
    @objc func upgradeSelector(notification: NSNotification) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        UltraViewControllerPresenter.presentOnTop(animated: true)
    }
    
    @objc func longPressOnTableView(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: rootView.tableView)
        let indexPath = rootView.tableView.indexPathForRow(at: location)
        
        if indexPath != nil && gestureRecognizer.state == .began {
            // Do haptic
            HapticHelper.doMediumHaptic()
            
            // Get the cell tapped as ChatBubbleTableViewCell
            guard let cell = rootView.tableView.cellForRow(at: indexPath!) as? ChatBubbleTableViewCell else {
                return
            }
            
            // Make sure cell has chatText
            guard let chatText = cell.chatText else {
                return
            }
            
            // Make sure chatText has attributedText
            guard let attributedText = chatText.attributedText else {
                return
            }
            
            // Don't show the copy text
            isLongPressForShare = true
            
            // Share text at row
            var text = attributedText.string
            
            if !PremiumHelper.get(), let shareURL = UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) {
                text = "\(text)\n\n\(Constants.copyFooterText)\n\(shareURL)"
            } else {
                text = "\(text)\n\n\(Constants.copyFooterText)"
            }
            
            ShareViewHelper.share(text, viewController: self)
            
            // Unbounce cell since it is a ChatTableViewCell which is always Bounceable
            cell.endBounce(completion: nil)
        }
    }
    
    @objc func addConversationPressed(_ sender: Any) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Pop and push to new conversation
        UIView.performWithoutAnimation {
            delegate?.popAndPushToNewConversation()
        }
    }
    
//    func appendToSources(_ source: CellSource, section: Int) {
//        DispatchQueue.main.async {
//            if self.sourcedTableViewManager.sources.count > section {
//                self.sourcedTableViewManager.sources[section].append(source)
//
//                UIView.performWithoutAnimation {
//                    self.rootView.tableView.reloadData()
//                }
//            } else {
//                self.sourcedTableViewManager.sources = [[source]]
//
//                UIView.performWithoutAnimation {
//                    self.rootView.tableView.reloadData()
//                }
////                Task {
////                    await self.setCellSource()
////                }
//            }
//
//        }
//    }
//
//    func deleteFromSources(_ source: CellSource, section: Int) {
//        DispatchQueue.main.async {
//            guard self.sourcedTableViewManager.sources.count > section else {
//                return
//            }
//
//            self.sourcedTableViewManager.sources[section].removeAll(where: {$0 === source})
//
//            UIView.performWithoutAnimation {
//                self.rootView.tableView.reloadData()
//            }
//        }
//    }
    
//    func scrollToBottom(animated: Bool) {
//        DispatchQueue.main.async {
//            // Ensure there is at least one section and one row in that section, otherwise return
//            guard self.rootView.tableView.numberOfSections > 0 && self.rootView.tableView.numberOfRows(inSection: 0) > 0 else {
//                return
//            }
//
//            // Scroll to the bottom row in the bottom section
//            self.rootView.tableView.scrollToRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.rootView.tableView.numberOfSections - 1) - 1, section: self.rootView.tableView.numberOfSections - 1), at: .bottom, animated: animated)
//        }
//    }
    
//    func setCellSource() async {
//        // Set sources as sourceArray and SmallBlankHeader if everything can be unwrapped and stuff
//        do {
//            if var currentConversation = self.currentConversation, let sourceArray = try await TableViewCellSourceFactory.makeChatTableViewCellSourceArray(from: &currentConversation, delegate: self) {
//                DispatchQueue.main.async {
//                    self.sourcedTableViewManager.sources = [sourceArray]
//
//                    UIView.performWithoutAnimation {
//                        self.rootView.tableView.reloadData()
//                    }
//                }
//                self.currentConversation = currentConversation
//            }
//
//            // Scroll if necessary
//            if shouldScrollOnFirstAppear {
//                DispatchQueue.main.async{
//                    let lastSection = self.rootView.tableView.numberOfSections - 1
//                    if lastSection >= 0 {
//                        let lastRow = self.rootView.tableView.numberOfRows(inSection: lastSection) - 1
//                        if lastRow >= 0 {
////                                self.rootView.tableView.scrollToBottom(animated: false)
//                            self.scrollToBottom(animated: false)
//                        }
//                    }
//                }
//            }
//        } catch {
//            print("Could not get sourceArray from currentConversation in viewDidLoad in ChatViewController... \(error)")
//        }
//    }
    
    func generateChat(inputText: String) async throws {
        // Add user's chat
        try await addChat(message: inputText, sender: Constants.Chat.Sender.user)
        
        // Start processing animation after a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startProcessingAnimation()
        }
        
        // Show ad or review
        if (PremiumHelper.get()) {
            showReviewAtFrequency()
        } else {
            showAdAtFrequency(shouldPresent: {shouldPresent in
                if !shouldPresent {
                    // If ad didn't present, try to show a review instead
                    self.showReviewAtFrequency()
                }
            })
        }
        
        // Get current model
        let currentModel = GPTModelHelper.getCurrentChatModel()
        
        // Get the current conversationID
        //        var conversationID: Int?
        //        if let currentConversationUnwrapped = currentConversation {
        //            conversationID = Int(currentConversationUnwrapped.conversationID)
        //        }
        
        // Get conversationID, otherwise set to -1 if nil TODO: Is the try? appropriate here?
        var currentConversationID = (try? await ConversationCDHelper.getConversationID(conversationObjectID: currentConversationObjectID!)) ?? -1
        
        // Build GetChatRequest
        let request = GetChatRequest(
            authToken: AuthHelper.get()!,
            inputText: inputText,
            conversationID: Int(currentConversationID),
            usePaidModel: GPTModelTierSpecification.paidModels.contains(where: {$0 == currentModel})
        )
        
        // Get stream :) TODO: Need to improve this!
        let stream = ChatWebSocketConnector.getChatStream(request: request)
        
        // So basically how this is going to work is it will create a chat with no text, then it'll update that managed object as new text comes in, then it will save it once all messages are received
        
        /* Insert AI Chat Cell */
        // Create source with chat inserted in it, setting currentConversation to updated conversation
//        guard let source: ChatTableViewCellSource = await {
//            do {
//                if var currentConversation = self.currentConversation, var chat = try await ChatCDHelper.appendChat(sender: Constants.Chat.Sender.ai, text: "", to: &currentConversation) {
//                    self.currentConversation = currentConversation
//                    
//                    return TableViewCellSourceFactory.makeChatTableViewCellSource(from: chat, isTyping: false, delegate: self)
//                }
//            } catch {
//                // TODO: Handle error
//                print("Could not unwrap currentConversation or create chat in source build in generateChat in ChatViewController... \(error)")
//            }
//            
//            return nil
//        }() else {
//            // TODO: Handle error, is stop processing animation enough?
//            stopProcessingAnimation()
//            
//            return
//        }
        
        // Create Chat variable
        var chatObjectID: NSManagedObjectID?
        
        /* Stream! */
        // Create a variable for the entire message
        var fullOutput: String = ""
        
        // Create null string which may be sent instead of an actual null response from the server
        let nullEquivalentString = "null"
        
        // Call "Finished Loading First Message" flow once when the messages load
        var firstMessage = true
        
        // Previous expected typing label height TODO: Renaming "typing label"?
        var previousExpectedTypingLabelHeight: CGFloat = 0.0
        
        // Important values to get as they come in
        var finishReason: String?
        var inputChatID: Int?
        var outputChatID: Int?
        var conversationID: Int?
        var remaining: Int?
        
        do {
            // Stream the messages to the chat cell
            for try await message in stream {
                if (firstMessage) {
                    /* Finished Loading First Message */
                    // Do haptic
                    HapticHelper.doLightHaptic()
                    
                    let shouldScroll = self.rootView.tableView.isAtBottom()
                    
                    // Stop processing animation (won't "stop again" if already stopped)
                    self.stopProcessingAnimation()
                    
                    // Instantaite Chat variable by appending to CoreData
                    chatObjectID = try await ChatCDHelper.appendChat(sender: Constants.Chat.Sender.ai, text: "", to: currentConversationObjectID!)
//                        self.sourcedTableViewManager.sources[self.chatSection].append(source)
//                        self.appendToSources(source, section: self.chatSection)
//                        self.appendToCoreDataAndUpdateTableView()
                    
//                    UIView.performWithoutAnimation {
//                        self.rootView.tableView.reloadData()
//                    }
                    
//                    if shouldScroll {
////                            self.rootView.tableView.scrollToBottom(animated: false)
//                        self.scrollToBottom(animated: false)
//                    }
                
                    
                    // Set firstChat to false
                    self.firstChat = false
                    
                    // Call inputTextViewOnFinishedGenerating to enable submitButton and cameraButton
                    rootView.inputTextViewOnFinishedGenerating()
                    
                    // Set firstMessage to false so all this is called once!
                    firstMessage = false
                    
//                    // Animate last row in to animate the inserted chat in
//                    DispatchQueue.main.async {
//                        self.animateLastRowIn()
//                    }
                }
                
                /* Parse Message */
                // Parse message to messageData
                var messageData: Data? = nil
                switch(message) {
                case .data(let data):
                    messageData = data
                case .string(let string):
                    messageData = string.data(using: .utf8)
                @unknown default:
                    print("Message wasn't string or data when parsing message stream! :O")
                }
                
                guard messageData != nil else {
                    print("No messageData found in a message in message stream! Skipping...")
                    continue
                }
                
                // Parse message to GetChatResponse
                let getChatResponse = try? JSONDecoder().decode(GetChatResponse.self, from: messageData!)
                
                // Ensure getChatResponse is not nil TODO: Should this be using do/catch?
                guard getChatResponse != nil else {
                    print("GetChatResponse could not be parsed! Skipping...")
                    continue
                }
                
                // Add outputText to fullOutput
                if let outputText = getChatResponse?.body.outputText {
                    fullOutput += outputText
                }
                
                // Pull out any important values as they come in, only the first time they are received
                if let gcrFinishReason = getChatResponse?.body.finishReason {
                    if gcrFinishReason.count > 0 && gcrFinishReason != nullEquivalentString && finishReason == nil {
                        finishReason = gcrFinishReason
                        
                        // Show popup if finish reason is limit TODO: Move this lol
                        if finishReason == FinishReasons.limit {
                            let ac = UIAlertController(title: "Limit Reached", message: "You've reached your daily chat limit. Upgrade for unlimited chats...", preferredStyle: .alert)
                            ac.view.tintColor = Colors.alertTintColor
                            ac.addAction(UIAlertAction(title: "Close", style: .cancel))
                            ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
                                self.goToUltraPurchase()
                            }))
                            
                            DispatchQueue.main.async {
                                self.present(ac, animated: true)
                            }
                        }
                    }
                }
                
                // Set inputChatID
                if let gcrInputChatID = getChatResponse?.body.inputChatID {
                    if gcrInputChatID > 0 && inputChatID == nil {
                        inputChatID = gcrInputChatID
                    }
                }
                
                // Set outputChatID
                if let gcrOutputChatID = getChatResponse?.body.outputChatID {
                    if gcrOutputChatID > 0 && outputChatID == nil {
                        outputChatID = gcrOutputChatID
                    }
                }
                
                // Set conversationID
                if let gcrConversationID = getChatResponse?.body.conversationID {
                    if gcrConversationID > 0 && conversationID == nil {
                        conversationID = gcrConversationID
                    }
                }
                
                // Set remaining
                if let gcrRemaining = getChatResponse?.body.remaining {
                    if remaining == nil {
                        remaining = gcrRemaining
                        
                        // Also update the remaining chats text here.. shh TODO: lol
                        updateGeneratedChatsRemaining(remaining: remaining!)
                    }
                }
                
                /* Update Chat Display with Message */
                
                DispatchQueue.main.async {
                    // Update typingLabel
                    let shouldScroll = self.rootView.tableView.isAtBottom()
//                    UIView.performWithoutAnimation {
                    Task {
                        try await ChatCDHelper.updateChat(chatObjectID: chatObjectID!, withText: fullOutput)
                        
                        self.rootView.tableView.performBatchUpdates({
                            // Update CoreData
//                            source.typingLabel?.text = fullOutput
                            
                        }, completion: {completion in
//                            if shouldScroll {
//                                self.scrollToBottom(animated: false)
//
////                                if let width = source.typingLabel?.frame.size.width {
////                                    let expectedTypingLabelSize = NSString(string: fullOutput)
////                                        .boundingRect(
////                                            with: CGSize(width: width, height: .infinity),
////                                            options: .usesLineFragmentOrigin,
////                                            attributes: [.font: source.typingLabel!.font!],
////                                            context: nil
////                                        )
////
////                                    if previousExpectedTypingLabelHeight < expectedTypingLabelSize.height {
////                                        //                                self.rootView.tableView.scrollToBottom(animated: false)
////                                        self.scrollToBottom(animated: false)
////                                    }
////                                }
//                            }
                        })
                    }
                }
            }
        } catch {
            // TODO: Are there any errors that would make this function return early? I don't think so right now, I think it's just the error for when the connection is closed which is fine because that means that it has received all the messages
        }
        
        // Unwrap chatObjectID and handle errors if it is still nil after the full chat has been received
        guard let chatObjectID = chatObjectID else {
            // Call inputTextViewOnFinishedGenerating to enable submitButton and cameraButton and stop processing animation to dismiss the loading cell in the case that there is no chatObjectID which would imply this was not called in firstChat TODO: Handle errors, also is this good enough?
            rootView.inputTextViewOnFinishedGenerating()
            stopProcessingAnimation()
            
            return
        }
        
        /* Finished Receiving All Messages */
        // Append finish reason text if finish reason is length
        if finishReason == FinishReasons.length && !PremiumHelper.get() {
            fullOutput += Constants.lengthFinishReasonAdditionalText
        }
            
//            // TODO: Animate this
////            DispatchQueue.main.async {
//            Task {
////                self.rootView.tableView.beginUpdates()
////                source.typingLabel?.text = fullOutput
////                self.rootView.tableView.endUpdates()
//                let shouldScroll = self.rootView.tableView?.isAtBottom()
//
//                do {
//                    // Update chat for the final time, and update latestChatDate and latestChatText in conversation TODO: Is it appropraite to do this here?
//
//                    try await ConversationCDHelper.updateConversation(conversationObjectID: currentConversationObjectID!, withLatestChatDate: Date())
//                    try await ConversationCDHelper.updateConversation(conversationObjectID: currentConversationObjectID!, withLatestChatText: fullOutput)
//                    try await ChatCDHelper.updateChat(chatObjectID: chatObjectID, withText: fullOutput)
//                } catch {
//                    // TODO: Handle errors
//                    print("Couldn't update chat in generateChat in ChatViewController")
//                }
//
//                if shouldScroll ?? false {
//                    self.rootView.tableView.scrollToBottom(animated: false)
//                }
//
////                if let width = source.typingLabel?.frame.size.width {
////                    let expectedAdditionalTextSize = NSString(string: Constants.lengthFinishReasonAdditionalText)
////                        .boundingRect(
////                            with: CGSize(width: width, height: .infinity),
////                            options: .usesLineFragmentOrigin,
////                            attributes: [.font: source.typingLabel!.font!],
////                            context: nil
////                        )
////
////                    // TODO: There may have to be an offset here..
////                    if self.rootView.tableView.isAtBottom(bottomHeightOffset: expectedAdditionalTextSize.height) {
//////                        self.rootView.tableView.scrollToBottom(animated: false)
//////                        self.rootView.tableView.scrollToBottomUsingOffset(animated: false)
////                        self.scrollToBottom(animated: false)
////                    }
////                }
//            }
//        }
        
        // Call inputTextViewOnFinishedTyping to disable softDisable
        rootView.inputTextViewOnFinishedTyping()
        
        do {
            // Package and save the complete chat and update the conversation conversationID and latestChatText
            guard let currentConversationObjectID = self.currentConversationObjectID else {
                // TODO: Handle errors
                return
            }
            try await ConversationCDHelper.updateConversation(conversationObjectID: currentConversationObjectID, withConversationID: Int64(conversationID ?? Constants.defaultConversationID))
            try await ConversationCDHelper.updateConversation(conversationObjectID: currentConversationObjectID, withLatestChatText: fullOutput)
            
            // Update the chat
            try await ChatCDHelper.updateChat(chatObjectID: chatObjectID, withText: fullOutput)
            
            // Update the user chat ID as inputChatID
            try await ChatCDHelper.updateChat(chatObjectID: chatObjectID, withChatID: Int64(inputChatID ?? Constants.defaultChatID))
            
            // Update the ai chat ID as outputChatID
            try await ChatCDHelper.updateChat(chatObjectID: chatObjectID, withChatID: Int64(outputChatID ?? Constants.defaultChatID))
            
            // Update the conversation latest chat text
            try await ConversationCDHelper.updateConversation(conversationObjectID: currentConversationObjectID, withLatestChatText: fullOutput)
            
            DispatchQueue.main.async {
//                UIView.performWithoutAnimation {
//                    self.rootView.tableView.reloadData()
//                }
            }
            
            // TODO: Handle scrolling
            
        } catch {
            // TODO: Handle errors
            stopProcessingAnimation()
            print("Error generting chat in ChatViewController... \(error)")
        }
    }
    
    func showFirstConversationChats() async throws {
        // Load and show first chats
        try await addChat(message: "Hi! I'm Prof. Write, your AI writing companion...", sender: Constants.Chat.Sender.ai)
        
        await withCheckedContinuation {continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + (!UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? 1.4 : 1.4), execute: {
                continuation.resume()
            })
        }
        
        try await self.addChat(message: "Ask me to write lyrics, poems, essays and more. Talk to me like a human and ask me anything you'd ask your professor!", sender: Constants.Chat.Sender.ai)
        
        await withCheckedContinuation {continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + (!UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? 1.4 : 1.4), execute: {
                continuation.resume()
            })
        }
        
        try await self.addChat(message: "I do better with more detail. Don't say, \"Essay on Belgium,\" say \"200 word essay on Belgium's cultural advances in the past 20 years.\" Remember, I'm your Professor, so use what I write as inspiration and never plagiarize!", sender: Constants.Chat.Sender.ai)
    }
    
    func showReviewAtFrequency() {
        // If the number remaining is not zero and its modulo with the review frequency is 0, show review TODO: Should this be determined by total chat count?
        if self.remaining > 0 && self.remaining % Constants.reviewFrequency == 0 && !firstChat {
            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    DispatchQueue.main.async {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
            }
        }
    }
    
    func showAdAtFrequency(shouldPresent: ((Bool)->Void)?) {
        // If the number remaining modulo the ad frequency is 0, show ad TODO: Should this be determined by total chat count?
        if self.remaining % Constants.adFrequency == 0  && self.remaining != 0 && !self.firstChat {
            shouldPresent?(true)
            
            if self.interstitial != nil {
                //Display ad
                DispatchQueue.main.async {
                    self.interstitial?.present(fromRootViewController: self)
                }
            } else {
                // Load if interstitial is nil
                loadGAD()
                
            }
        } else {
            shouldPresent?(false)
        }
    }
    
    func goToUltraPurchase() {
        UltraViewControllerPresenter.presentOnTop(animated: true)
    }
    
    func goToCameraView() {
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = self
        cameraViewController.modalPresentationStyle = .overFullScreen
        present(cameraViewController, animated: true)
    }
    
    func goToSettingsView() {
        navigationController?.pushViewController(SettingsPresentationSpecification().viewController, animated: true)
    }
    
//    func deleteAllLoadingSources() {
//        DispatchQueue.main.async {
//            self.sourcedTableViewManager.sources[self.chatSection].removeAll(where: {$0 is LoadingTableViewCellSource})
//
//            UIView.performWithoutAnimation {
//                self.rootView.tableView.reloadData()
//            }
//        }
//    }
    
    func startProcessingAnimation() {
        if !isProcessingChat {
            isProcessingChat = true
            
            // Do these on main thread
            DispatchQueue.main.async {
                // Save if should scroll and insert loading row
                let shouldScroll = self.rootView.tableView.isAtBottom()//self.rootView.tableView.isAtBottom(bottomHeightOffset: (self.rootView.tableView.cellForRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.chatSection) - 1, section: self.chatSection))?.frame.height ?? 0) + 40.0)
                
                // Set fetchedResultsTableViewDataSource showLoading flag to enabled and reload tableView
                self.fetchedResultsTableViewDataSource?.showLoadingCell()
                
                // Animate last row in to the loading cell in :)
                self.animateLastRowIn()
                
//                self.rootView.tableView.reloadData()
                
//                let loadingChatTableViewCellSource = LoadingChatTableViewCellSource()
//                self.sourcedTableViewManager.sources[self.chatSection].append(loadingChatTableViewCellSource)
                
//                UIView.performWithoutAnimation {
//                    self.rootView.tableView.reloadData()
//                }
                
//                // Do scroll!
//                if shouldScroll {
////                    self.rootView.tableView.scrollToBottom(animated: false)
//                    //                    self.rootView.tableView.scrollToBottomUsingOffset(animated: false)
//                    //                    self.rootView.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false) // TODO: - Do scrolling queue or something
//                    self.scrollToBottom(animated: false)
//                }
                
//                DispatchQueue.main.async {
//                    if let loadingCell = self.fetchedResultsTableViewDataSource?.getLoadingCell() {
////                        self.animateLastRowIn()
//                        self.animateViewIn(view: loadingCell)
//                    }
//                }
            }
        }
    }
    
    func stopProcessingAnimation() {
        if isProcessingChat {
            isProcessingChat = false
            
            // Set loading flag to false and reload tableView
            self.fetchedResultsTableViewDataSource?.hideLoadingCell()
//            self.rootView.tableView.reloadData()
//            deleteAllLoadingSources()
        }
    }
    
    func addChat(message: String, sender: String, forceAnimation: Bool = false) async throws {
//        func shouldType(chat: Chat) -> Bool {
//            chat.sender == Constants.Chat.Sender.ai
//        }
        
        // Create chat and source getting currentConversation and setting it to updated currentConversation
//        guard let source: ChatTableViewCellSource = try await {
//            // Unwrap currentConversation and chat
//            guard var currentConversation = currentConversation, let chat = try await ChatCDHelper.appendChat(sender: sender, text: message, to: currentConversation.objectID) else {
//                // TODO: Handle errors, maybe throw one since this throws
//                return nil
//            }
//sdf
//            // Update currentConversation to new context
//            self.currentConversation = currentConversation
//
//            // Make source and return
//            return TableViewCellSourceFactory.makeChatTableViewCellSource(from: chat, isTyping: shouldType(chat: chat), delegate: self)
//        }() else {
//            // TODO: Handle errors, maybe throw one since this throws
//            return nil
//        }
        
        // Don't animate insertion if forceAnimation is false, the previous row was a loading row, meaning it isProcessingChat and the sender was ai TODO: Or should it just be not the user?
        var shouldAnimateIn: Bool
        if !forceAnimation && isProcessingChat && sender == Constants.Chat.Sender.ai {
            shouldAnimateIn = false
        } else {
            shouldAnimateIn = true
        }
        
//        // Do scrolling and insertion on main thread
//        DispatchQueue.main.async {
        Task {
            // Save if user should scroll if tableView is at (or near) the bottom
            let shouldScroll = self.rootView.tableView.isAtBottom()
            
            // Insert row and append created source to chatRowSources!
            //            self.appendToSources(source, section: self.chatSection) TODO: Here I commented out something that's interesting
            
            do {
                // Append chat using ChatCDHelper
                try await ChatCDHelper.appendChat(sender: sender, text: message, to: currentConversationObjectID!)
            } catch {
                // TODO: Handle errors
                print("Error appending chat to ChatCDHelper.. \(error)")
            }
            
            DispatchQueue.main.async {
//                // Scroll if shouldScroll
//                if shouldScroll {
//                    self.scrollToBottom(animated: false)
//                }

                // Do animate in animation
                if shouldAnimateIn {
                    //                    self.animateChatRowIn(view: source.view)
                    self.animateLastRowIn()
                }
            }
            
            //        // Create and start a new Typewriter for the AI response
            //        if sender == Constants.Chat.Sender.ai {
            //            // Setup prevExpectedHeight and timeInterval for checking to scroll
            //            var prevExpectedHeight: CGFloat = 0
            //            let timeInterval = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? Constants.premiumTypingTimeInterval : Constants.freeTypingTimeInterval
            //
            //            // Setup default width and font for checking to scroll
            //            let defaultWidth = view.frame.size.width * 0.8
            //            let defaultFont = UIFont(name: Constants.primaryFontName, size: 17.0)!
            //
            //            // Create writing task for typing letters
            //            let writingTask = DispatchWorkItem {
            //                // Type each letter!
            //                for c in source.chat.text! {
            //                    DispatchQueue.main.async {
            //                        source.typingText.append(c)
            //                        source.typingLabel?.text = source.typingText
            //
            //                        let expectedTypingLabelSize = NSString(string: source.typingText).boundingRect(
            //                            with: CGSize(width: source.typingLabel?.frame.size.width ?? defaultWidth, height: .infinity),
            //                            options: .usesLineFragmentOrigin,
            //                            attributes: [.font: source.typingLabel?.font ?? defaultFont],
            //                            context: nil)
            //                        if prevExpectedHeight < expectedTypingLabelSize.height {
            //                            // Reload for size enlargement
            //                            //                            self.rootView.tableView.reloadData()
            //
            //                            if self.rootView.tableView.isAtBottom(bottomHeightOffset: prevExpectedHeight) {
            ////                                self.rootView.tableView.scrollToBottomUsingOffset(animated: false)
            //                                self.scrollToBottom(animated: false)
            //                            }
            //
            //                            // Reload for size enlargement
            //                            UIView.performWithoutAnimation {
            //                                self.rootView.tableView.reloadData()
            //                            }
            //
            //                            prevExpectedHeight = expectedTypingLabelSize.height
            //                        }
            //                    }
            //
            //                    Thread.sleep(forTimeInterval: timeInterval)
            //                }
            //
            //                // Set source isTyping to false
            //                source.isTyping = false
            //            }
            
            //            let queue: DispatchQueue = .init(label: "typing", qos: .userInteractive)
            //            queue.async(execute: writingTask)
            
            //            let typewriter = Typewriter(
            //                toTypeString: chat.text!,
            //                delay: timeInterval,
            //                typingUpdateLetterCount: chat.text!.count/Constants.defaultTypingUpdateLetterCountFactor + 1)
            //
            //            while let currentText = await typewriter.next() {
            //                // Try to scroll if content height has increased and at bottom TODO: - Is this cool to do if there are multiple filling at once? What if there is some sort of future update?
            //                if source.typingLabel != nil {
            //                    let expectedTypingLabelSize = NSString(string: currentText).boundingRect(
            //                        with: CGSize(width: source.typingLabel!.frame.size.width, height: .infinity),
            //                        options: .usesLineFragmentOrigin,
            //                        attributes: [.font: source.typingLabel!.font!],
            //                        context: nil)
            //                    if prevExpectedHeight < expectedTypingLabelSize.height {
            //                        // Reload for size enlargement
            //                        //                            self.rootView.tableView.reloadData()
            //
            //                        if self.rootView.tableView.isAtBottom(bottomHeightOffset: prevExpectedHeight) {
            //                            self.rootView.tableView.scrollToBottomUsingOffset(animated: false)
            //                        }
            //
            //                        // Reload for size enlargement
            //                        self.rootView.tableView.reloadData()
            //
            //                        prevExpectedHeight = expectedTypingLabelSize.height
            //                    }
            //                }
            //
            //                // Update the label in the tableView!
            //                source.typingLabel?.text = currentText
            //            }
            
            // Call inputTextViewOnFinishedTyping
            self.rootView.inputTextViewOnFinishedTyping()
//        }
        }
        
//        return source
    }
    
    func animateLastRowIn() {
        // Get last row of first section with guard let TODO: Not the best solution I don't think
        guard rootView.tableView.numberOfSections > 0, let lastRowFirstSection = rootView.tableView.cellForRow(at: IndexPath(row: rootView.tableView.numberOfRows(inSection: 0) - 1, section: 0)) else {
            return
        }
        
        animateViewIn(view: lastRowFirstSection)
        
//        DispatchQueue.main.async {
//        lastRowFirstSection.alpha = 0.0
//        lastRowFirstSection.transform = CGAffineTransform(translationX: 0, y: 20)
//        UIView.animate(withDuration: 0.2, animations: {
//            lastRowFirstSection.alpha = 1.0
//            lastRowFirstSection.transform = CGAffineTransform(translationX: 0, y: 0)
//        })
//        }
    }
    
    func animateViewIn(view: UIView) {
        view.alpha = 0.0
        view.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 1.0
            view.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    func dismissKeyboard() {
//        // Move the view down faster than the keyboard
//        UIView.animate(withDuration: 0.11, delay: 0.0, options: .curveEaseInOut, animations: {
//            if self.rootView.bottomViewBottomAlignmentConstraint.constant != self.originalBottomViewBottomAlignmentConstraintConstant {
//                self.rootView.bottomViewBottomAlignmentConstraint.constant = self.originalBottomViewBottomAlignmentConstraintConstant
//                if let prevContentOffsetFactor = self.prevContentOffsetFactor {
//                    self.rootView.tableView.contentOffset.y -= self.prevContentOffsetFactor
//                }
//                self.rootView.layoutIfNeeded()
//            }
////            if self.view.frame.origin.y != self.origin {
////                self.view.frame.origin.y = self.origin
////            }
//        })
        
        view.endEditing(true)
    }
    
    func loadGAD() {
        failedToLoadInterstitial = false
        
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: Private.interstitialID, request: request, completionHandler: { [self] ad, error in
                if let error = error {
                    print("Failed to load ad with error: \(error.localizedDescription)")
                    self.failedToLoadInterstitial = true
                    
                    return
                }
                
                interstitial = ad
                interstitial?.fullScreenContentDelegate = self
                failedToLoadInterstitial = false
            })
        }
    }
    
    /* GPT Model Control */
    
    func setGPTViewElements() {
        let defaultAnimationDuration = 1.4
        let defaultAnimationRepeatCount = 1
        
        // Setup imageView animation
        if traitCollection.userInterfaceStyle == .light {
            // Setup imageView animation
            rootView.gptModelView.imageView.image = UIImage.gifFirstFrameWithName(ChatGPTModelViewComponents.lightGifName)
            rootView.gptModelView.imageView.animationImages = UIImage.gifToArrayWithName(ChatGPTModelViewComponents.lightGifName)
        } else {
            rootView.gptModelView.imageView.image = UIImage.gifFirstFrameWithName(ChatGPTModelViewComponents.darkGifName)
            rootView.gptModelView.imageView.animationImages = UIImage.gifToArrayWithName(ChatGPTModelViewComponents.darkGifName)
        }
        
        rootView.gptModelView.imageView.animationDuration = defaultAnimationDuration
        rootView.gptModelView.imageView.animationRepeatCount = defaultAnimationRepeatCount
        
        // Setup text
        rootView.gptModelView.additionalTextLabel.text = ChatGPTModelViewComponents.additionalText
        rootView.gptModelView.modelTextLabel.text = ChatGPTModelViewComponents.modelName
        
        // Set gptModelView view to needs layout for shadow to update
        DispatchQueue.main.async {
            self.rootView.gptModelView.shadowView.setNeedsDisplay()
        }
        
        // Start animation
        startAnimationTimer()
    }
    
    private func startAnimationTimer() {
        if !SettingsHelper.shouldReduceMotion() && (gptModelNameAnimationTimer == nil || !gptModelNameAnimationTimer!.isValid) {
            gptModelNameAnimationTimer = Timer.scheduledTimer(timeInterval: defaultGPTModelNameAnimationDuration, target: self, selector: #selector(doGPTModelNameAnimation), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func doGPTModelNameAnimation() {
        rootView.gptModelView.imageView.startAnimating()
        gptModelNameAnimationPlayedCount += 1
        
        gptModelNameAnimationTimer = Timer.scheduledTimer(timeInterval: defaultGPTModelNameAnimationDuration * Double(gptModelNameAnimationPlayedCount + 1), target: self, selector: #selector(doGPTModelNameAnimation), userInfo: nil, repeats: false)
    }
    
    @objc private func didPressGPTModelNameButton() {
        let popupController = ChatGPTModelSelectionViewController()
        popupController.delegate = self
        //        addChild(popupController)
        popupController.modalPresentationStyle = .overCurrentContext
        tabBarController!.present(popupController, animated: false)
        
    }
    
}

