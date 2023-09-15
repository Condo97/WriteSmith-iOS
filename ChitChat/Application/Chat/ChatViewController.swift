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
    
    var banner: GADBannerView!
    
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
    
    lazy var fetchedResultsTableViewDataSource: ChatTableViewDataSource<Chat>? = {
        guard let currentConversationObjectID = currentConversationObjectID else {
            // Must have currentConversation.. TODO: Handle errors!
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Chat> = Chat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), currentConversationObjectID)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)
        ]
        
        return ChatTableViewDataSource<Chat>(
            tableView: rootView.tableView,
            managedObjectContext: CDClient.mainManagedObjectContext,
            fetchRequest: fetchRequest,
            cacheName: nil,
            pulsatingDotsLoadingCellReuseIdentifier: Registry.Chat.View.Table.Cell.loading.reuseID,
            editingDelegate: nil,
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
        
        // TODO: The animation is a little jumpy when the first chats are loaded, fix it!
        
        /* Setup Delegates */
//        sourcedTableViewManager.delegate = self
        
        rootView.inputTextView.delegate = self
        rootView.tableView.delegate = self
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
        rootView.upgradeNowPromoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upgradeSelector)))
        
        // Long press for message share sheet
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnTableView))
        longPressGestureRecognizer.cancelsTouchesInView = false
        longPressGestureRecognizer.minimumPressDuration = 0.4
        rootView.tableView.addGestureRecognizer(longPressGestureRecognizer)
        
        // Set remaining view to transparent before it loads
        rootView.upgradeNowPromoView.alpha = 0.0
        
        // Set gpt model tap gesture recognizer
        let gptModelNameViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressGPTModelNameButton))
        rootView.gptModelView.addGestureRecognizer(gptModelNameViewTapGestureRecognizer)
        
        // Set gpt model text and image
        setGPTViewElements()
        	
        /* Setup ad view and ads */
//        interstitial?.fullScreenContentDelegate = self
        
        rootView.adView.alpha = 0.0
        rootView.adViewHeightConstraint.constant = 0.0
        
        banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = Private.bannerID
        banner.rootViewController = self
        banner.delegate = self
        
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            banner.load(GADRequest())
            
            Task {
                await InterstitialAdManager.instance.loadAd()
            }
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
        
//        // Scroll to bottom if shouldScrollOnFirstAppear
//        if shouldScrollOnFirstAppear {
//            DispatchQueue.main.async {
//                self.rootView.tableView.scrollToBottomRow(animated: false)
//            }
//        }
        
        // Start random promo text task
        startRandomPromoTextTask()
        
        // Mirror tableView upside down
        rootView.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
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
            goToUltraPurchase()
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
            self.rootView.upgradeNowPromoView.isHidden = isPremium
            self.rootView.upgradeNowPromoShadowView.isHidden = isPremium
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
    
//    override func updateGeneratedChatsRemaining(remaining: Int) {
//        super.updateGeneratedChatsRemaining(remaining: remaining)
//
//        // Set instance remaining
//        self.remaining = remaining
//
//        // Set upgradeNowPromoLabel on main queue
//        DispatchQueue.main.async {
//            self.rootView.upgradeNowPromoLabel.text = "You have \(remaining < 0 ? 0 : remaining) chat\(remaining == 1 ? "" : "s") remaining today..."
//
//            // If the upgradeNowPromoView is transparent, show it now that generated chats remaining has loaded
//            if self.rootView.upgradeNowPromoView.alpha == 0.0 {
//                UIView.animate(withDuration: 0.4, animations: {
//                    self.rootView.upgradeNowPromoView.alpha = 1.0
//                })
//            }
//        }
//    }
    
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
        
        // Insert rightBarButtonItem as first item
        navigationItem.rightBarButtonItems?.insert(plusBarButtonItem, at: 0)
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
//                    self.rootView.tableView.contentOffset.y += offset
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
//                self.rootView.tableView.contentOffset.y -= prevContentOffsetFactor
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
    
    func generateChat(inputText: String) async throws {
        // Add user's chat
        try await addChat(message: inputText, sender: Constants.Chat.Sender.user)
        
        // Start processing animation and face idle animation to thinking after a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startProcessingAnimation()
            self.setFaceIdleAnimationToThinking()
        }
        
        // Call showPromoPopupWhileGenerating to show ad or review
        Task {
            await showPromoPopupWhileGenerating()
        }
        
        // Get current model
        let currentModel = GPTModelHelper.getCurrentChatModel()
        
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
        
        // Create Chat variable
        var chatObjectID: NSManagedObjectID?
        
        /* Stream! */
        // Create a variable for the entire message
        var fullOutput: String = ""
        
        // Create null string which may be sent instead of an actual null response from the server
        let nullEquivalentString = "null"
        
        // Call "Finished Loading First Message" flow once when the messages load
        var firstMessage = true
        
        // Previous table view content height TODO: Renaming "typing label"?
        var prevTableViewContentHeight: CGFloat = 0.0
        
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
                    
                    // Set face idle animation to thinking
                    setFaceIdleAnimationToThinking()
                    
                    // Get chatObjectID by appending chat to CoreData
                    chatObjectID = try await ChatCDHelper.appendChat(sender: Constants.Chat.Sender.ai, text: "", to: currentConversationObjectID!)
                    
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
                
//                // Set remaining
//                if let gcrRemaining = getChatResponse?.body.remaining {
//                    if remaining == nil {
//                        remaining = gcrRemaining
//
//                        // Also update the remaining chats text here.. shh TODO: lol
//                        updateGeneratedChatsRemaining(remaining: remaining!)
//                    }
//                }
                
                /* Set Do Line Update Scroll */
                
                // If the current tableView content size is larger than the previous one, set to doLineUpdateScroll
                if rootView.tableView.contentSize.height > prevTableViewContentHeight {
                    // Set prevTableViewContentHeight to current tableView content height
                    prevTableViewContentHeight = rootView.tableView.contentSize.height
                    
                    // Set fetchedResultsTableViewDataSource doLineUpdateScroll to true
                    fetchedResultsTableViewDataSource?.doLineUpdateScroll = true
                }
                
                /* Update Chat Display with Message */
                
                DispatchQueue.main.async {
                    Task {
                        // Update chat
                        try await ChatCDHelper.updateChat(chatObjectID: chatObjectID!, withText: fullOutput)
                    }
                }
            }
        } catch {
            // TODO: Are there any errors that would make this function return early? I don't think so right now, I think it's just the error for when the connection is closed which is fine because that means that it has received all the messages
            print("Error streaming chat in generateChat in ChatViewController.. \(error)")
        }
        
        self.setFaceIdleAnimationToSmile()
        
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
    
    func startRandomPromoTextTask(displayDuration seconds: UInt64 = 15) {
        Task {
            let upgradeNowPromoViewAnimationDuration = 0.4
            let maxCatchCount = 10
            var catchCount = 0
            while (catchCount < maxCatchCount) {
                // Wait first since we want this to initially show up as the user is using the app after some delay
                do {
                    // Wait
                    try await Task.sleep(nanoseconds: seconds * 1_000_000_000)
                } catch {
                    // If the catch block is triggered, increment catchCount which may exit the while loop if it throws too many and continue
                    print("Could not sleep when displaying random promo text in ChatViewController, going to do this \(maxCatchCount - catchCount) more times before exiting the while loop... \(error)")
                    catchCount += 1
                    continue
                }
                
                // Animate upgradeNowPromoView alpha to 0 before changing text
                UIView.animate(withDuration: upgradeNowPromoViewAnimationDuration) {
                    self.rootView.upgradeNowPromoView.alpha = 0.0
                } completion: {success in
                    // Set the promo label text to a random upgrade now promo text
                    self.rootView.upgradeNowPromoLabel.text = PromoTextGenerator.randomUpgradeNowPromoText(differentThan: self.rootView.upgradeNowPromoLabel.text)
                }
                
                // Wait one tenth of the seconds duration and then animate upgradeNowPromoView alpha to 1.0
                do {
                    // Wait
                    try await Task.sleep(nanoseconds: UInt64((upgradeNowPromoViewAnimationDuration + Double(seconds) / 10.0) * 1_000_000_000))
                } catch {
                    // If the catch block is triggered, increment catchCount which may exit the while loop if it throws too many and continue
                    print("Could not sleep when displaying random promo text in ChatViewController, going to do this \(maxCatchCount - catchCount) more times before exiting the while loop... \(error)")
                    catchCount += 1
                    continue
                }
                
                UIView.animate(withDuration: upgradeNowPromoViewAnimationDuration) {
                    self.rootView.upgradeNowPromoView.alpha = 1.0
                }
            }
        }
    }
    
    func shouldShowReviewAtFrequency(chatCount: Int) -> Bool {
        // If the number remaining is not zero and its modulo with the review frequency is 0, show review TODO: Should this be determined by total chat count?
        if chatCount > 1 && chatCount % Constants.reviewFrequency == 0 {
            return true
        }
        
        return false
    }
    
    func shouldShowAdAtFrequency(chatCount: Int) async -> Bool {
        // If the number remaining modulo the ad frequency is 0, show ad TODO: Should this be determined by total chat count?
        if chatCount > 1 && chatCount % Constants.adFrequency == 0 {
            return true
        }
        
        return false
    }
    
    func shouldShowPremiumAtFrequency(chatCount: Int) -> Bool {
        if chatCount > 1 && chatCount & Constants.premiumFrequency == 0 {
            return true
        }
        
        return false
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
    
    func startProcessingAnimation() {
        if !isProcessingChat {
            isProcessingChat = true
            
            // Set fetchedResultsTableViewDataSource doLineUpdateScroll to true
            fetchedResultsTableViewDataSource?.doLineUpdateScroll = true
            
            // Do these on main thread
            DispatchQueue.main.async {
                // Save if should scroll and insert loading row
                let shouldScroll = self.rootView.tableView.isAtBottom()//self.rootView.tableView.isAtBottom(bottomHeightOffset: (self.rootView.tableView.cellForRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.chatSection) - 1, section: self.chatSection))?.frame.height ?? 0) + 40.0)
                
                // Set fetchedResultsTableViewDataSource showLoading flag to enabled and reload tableView
                self.fetchedResultsTableViewDataSource?.showLoadingCell()
                
                // Animate last row in to the loading cell in :)
                self.animateFirstRowIn()
                
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
    
    func setFaceIdleAnimationToSmile() {
        // Set idle animations to smile
        if let globalTabBarController = tabBarController as? GlobalTabBarController {
            globalTabBarController.faceAnimationController?.setIdleAnimations(RandomFaceIdleAnimationSequence.smile)
        }
    }
    
    func setFaceIdleAnimationToThinking() {
        // Set idle animations to thinking
        if let globalTabBarController = tabBarController as? GlobalTabBarController {
            globalTabBarController.faceAnimationController?.setIdleAnimations(RandomFaceIdleAnimationSequence.thinking)
        }
    }
    
    func setFaceIdleAnimationToWriting() {
        // Set idle animations to thinking
        if let globalTabBarController = tabBarController as? GlobalTabBarController {
            globalTabBarController.faceAnimationController?.setIdleAnimations(RandomFaceIdleAnimationSequence.writing)
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
        
        // Set fetchedResultsTableViewDataSource doLineUpdateScroll to true
        fetchedResultsTableViewDataSource?.doLineUpdateScroll = true
        
        Task {
            
            do {
                // Append chat using ChatCDHelper
                try await ChatCDHelper.appendChat(sender: sender, text: message, to: currentConversationObjectID!)
            } catch {
                // TODO: Handle errors
                print("Error appending chat to ChatCDHelper.. \(error)")
            }
            
            DispatchQueue.main.async {
                // Do animate in animation
                if shouldAnimateIn {
                    self.animateFirstRowIn()
                }
            }
            
            // Call inputTextViewOnFinishedTyping
            self.rootView.inputTextViewOnFinishedTyping()
//        }
        }
        
//        return source
    }
    
    func deleteChat(_ chat: Chat) {
        // Show prompt for user to confirm deletion
        let ac = UIAlertController(
            title: "Delete Chat",
            message: "Are you sure you want to delete this chat?",
            preferredStyle: .alert)
        ac.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: {action in
                Task {
                    do {
                        // Unwrap authToken, otherwise return
                        guard let authToken = AuthHelper.get() else {
                            print("Could not unwrap AuthToken in ChatViewController ChatTableViewCellSourceDelegate!")
                            return
                        }

                        // Create deleteChatRequest and delete Chat from server
                        let deleteChatRequest = DeleteChatRequest(
                            authToken: authToken,
                            chatID: Int(chat.chatID))

                        let deleteChatStatusResponse = try await HTTPSConnector.deleteChat(request: deleteChatRequest)

                        // Delete chat in core data
                        try await ChatCDHelper.deleteChat(chatObjectID: chat.objectID)

                    } catch {
                        // TODO: Handle error
                        print("Could not delete chat in delete in ChatViewController ChatTableViewCellSourceDelegate... \(error)")
                    }


                }
            }))
        ac.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel))
        
        DispatchQueue.main.async {
            self.present(ac, animated: true)
        }
    }
    
    func animateFirstRowIn() {
        // Get first row of first section with guard let TODO: Not the best solution I don't think
        guard rootView.tableView.numberOfSections > 0 && rootView.tableView.numberOfRows(inSection: 0) > 0, let firstRowFirstSectionCell = rootView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) else {
            return
        }
        
        animateTableViewCellIn(tableViewCell: firstRowFirstSectionCell)
        
//        DispatchQueue.main.async {
//        lastRowFirstSection.alpha = 0.0
//        lastRowFirstSection.transform = CGAffineTransform(translationX: 0, y: 20)
//        UIView.animate(withDuration: 0.2, animations: {
//            lastRowFirstSection.alpha = 1.0
//            lastRowFirstSection.transform = CGAffineTransform(translationX: 0, y: 0)
//        })
//        }
    }
    
    func animateTableViewCellIn(tableViewCell: UITableViewCell) {
        let movementTransform = CGAffineTransform(translationX: 0, y: -100)
        
        tableViewCell.contentView.alpha = 0.0
        tableViewCell.transform = tableViewCell.transform.concatenating(movementTransform)
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 4.0) {
//        UIView.animate(withDuration: 0.4, animations: {
            tableViewCell.contentView.alpha = 1.0
            tableViewCell.transform = tableViewCell.transform.concatenating(movementTransform.inverted())
        }
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
    
    private func showPromoPopupWhileGenerating() async {
        let chatCount: Int
        do {
            // Get chatCount
            guard let currentConversationObjectID = currentConversationObjectID, let chatCountUnwrapped = try await ConversationCDHelper.countChats(in: currentConversationObjectID) else {
                print("Could not unwrap currentConversationObjectID or chatCount in ChatViewController!")
                return
            }
            
            chatCount = chatCountUnwrapped
        } catch {
            // TODO: Handle errors
            print("Error showing promo popup while generating in ChatViewController... \(error)")
            return
        }
        
        // Show only one popup at correct frequency depending on premium
        if (PremiumHelper.get()) {
            if shouldShowReviewAtFrequency(chatCount: chatCount) {
                // Show review, only returning if shown
                DispatchQueue.main.async {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        DispatchQueue.main.async {
                            SKStoreReviewController.requestReview(in: scene)
                            
                            return
                        }
                    }
                }
            }
        } else {
            if await shouldShowAdAtFrequency(chatCount: chatCount) {
                // Show ad
                await InterstitialAdManager.instance.showAd(from: self)
                
                return
            }
            
            if shouldShowReviewAtFrequency(chatCount: chatCount) {
                // Show review, only returning if shown
                DispatchQueue.main.async {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        DispatchQueue.main.async {
                            SKStoreReviewController.requestReview(in: scene)
                            
                            return
                        }
                    }
                }
            }
            
            if shouldShowPremiumAtFrequency(chatCount: chatCount) {
                // Show premium
                goToUltraPurchase()
                
                return
            }
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

