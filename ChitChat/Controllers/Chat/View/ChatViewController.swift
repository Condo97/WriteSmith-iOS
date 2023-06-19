//
//  MainViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import UIKit
import StoreKit
import GoogleMobileAds

protocol ChatViewControllerDelegate {
    func popAndPushToNewConversation()
}

class ChatViewController: HeaderViewController {
    
    // Constants
    let promoViewHeightConstraintConstant = 50.0
    
    let chatSection = 0
    let spacerSection = 1
    
    let sourcedTableViewManager: SourcedTableViewManagerProtocol = {
        var sbhstvm = ChatSmallBlankHeaderSourcedTableViewManager()
        sbhstvm.blankHeaderHeight = 40.0
        return sbhstvm
    }()
    
    // Instance variables
    var origin: CGFloat = 0.0
    
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
    var currentConversation: Conversation? {
        didSet {
            ConversationResumingManager.conversation = currentConversation
        }
    }
    
    var shouldShowUltra = false
    var loadFirstConversationChats = false
    var delegate: ChatViewControllerDelegate?
    
    
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
        sourcedTableViewManager.delegate = self
        
        rootView.inputTextView.delegate = self
        rootView.tableView.manager = sourcedTableViewManager
        
        /* Set TableView touchDelegate */
        rootView.tableView.touchDelegate = self
        
        /* Register Nibs TODO: Should this just be in ChatTableView? How can this be dynamic? */
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.user, to: rootView.tableView)
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.ai, to: rootView.tableView)
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.padding, to: rootView.tableView)
        RegistryHelper.register(Registry.Chat.View.TableView.Cell.loading, to: rootView.tableView)
        
        /* Setup UI Stuff */
        // Set tableView estimated row height and row height to automatic dimension
        rootView.tableView.estimatedRowHeight = 44.0
        rootView.tableView.rowHeight = UITableView.automaticDimension
        
        // Set submitButton to be enabled and cameraButton to be not enabled
        rootView.submitButton.isEnabled = false
        rootView.cameraButton.isEnabled = true
        
        // Set the navigationController view backgroundColor so when the keyboard shows there won't be a black space during the animation due to the different speeds of keyboard and view animation
        navigationController!.view.backgroundColor = Colors.chatBackgroundColor
        
        print("hi")
        
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
        longPressGestureRecognizer.minimumPressDuration = 1.0
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
        
        /* Setup Cell Source */
        // Insert all chats from conversation into sources
        sourcedTableViewManager.sources.insert(TableViewCellSourceFactory.makeChatTableViewCellSourceArray(from: currentConversation!), at: chatSection)
        
        // Set up default tiered padding source at index 1 in spacerSection
//        sourcedTableViewManager.sources.insert([TieredPaddingTableViewCellSource()], at: spacerSection)
        
        // If first time launch, set shouldShowUltra to false
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultNotFirstLaunch) {
            shouldShowUltra = false
            UserDefaults.standard.set(true, forKey: Constants.userDefaultNotFirstLaunch)
        }
        
        // Initial updates
        updateInputTextViewSize(textView: rootView.inputTextView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update premium items with stored status
        //updatePremium(isPremium: PremiumHelper.get())
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if shouldScrollOnFirstAppear {
            DispatchQueue.main.async{
                let lastSection = self.rootView.tableView.numberOfSections - 1
                if lastSection >= 0 {
                    let lastRow = self.rootView.tableView.numberOfRows(inSection: lastSection) - 1
                    if lastRow >= 0 {
                        self.rootView.tableView.scrollToRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.rootView.tableView.numberOfSections - 1) - 1, section: self.rootView.tableView.numberOfSections - 1), at: .bottom, animated: false)
                    }
                }
            }
        }
        
        // Set the camera button constraints
        if !cameraButtonHeightConstraintSet && rootView.isBlankWithPlaceholder {
            rootView.cameraButtonHeightConstraint.constant = rootView.inputBackgroundView.frame.height
            
            cameraButtonHeightConstraintSet = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set shouldScrollOnFirstAppear to false, as it should have finished scrolling on the viewDidLayoutSubviews call right before viewDidAppear
        shouldScrollOnFirstAppear = false
        
        // Set origin for keyboard
        origin = self.view.frame.origin.y
        
        // Show Ultra Purchase on launch if not premium
        if shouldShowUltra && !PremiumHelper.get() {
            shouldShowUltra = false
            goToUltraPurchase()
        }
        
        // Show first conversation chats or add chat from first chat generator TODO: This all should be done somewhere else
        if loadFirstConversationChats {
            showFirstConversationChats()
        } else {
            // Only add if there are no chats in the conversation
            if currentConversation?.chats?.count == 0 {
                addChat(message: FirstChatGenerator.getRandomFirstChat(), sender: Constants.Chat.Sender.ai)
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
            
            // Set tableView manager footer height
            if let stvm = self.sourcedTableViewManager as? SourcedTableViewManager {
                self.rootView.tableView.beginUpdates()
                stvm.lastSectionFooterHeightAddition = isPremium ? Constants.Chat.View.Table.ultraFooterHeight : Constants.Chat.View.Table.freeFooterHeight
                self.rootView.tableView.endUpdates()
            }

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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == self.origin {
                //TODO: - In the previous version, the -tabBarController.tabBar.frame.size.height wasn't necessary, but now it is otherwise a black box the size of the tabBar will show up
                if let tabBarController = UIApplication.shared.topmostViewController()?.tabBarController {
                    self.view.frame.origin.y -= (keyboardSize.height - tabBarController.tabBar.frame.size.height)
                } else {
                    view.endEditing(true)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
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
            
            if let shareURL = UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) {
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
        delegate?.popAndPushToNewConversation()
    }
    
    func generateChat(inputText: String) {
        // Add user's chat
        addChat(message: inputText, sender: Constants.Chat.Sender.user)
        
        // Start processing animation
        startProcessingAnimation()
        
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
        
        // Build GetChatRequest
        let request = GetChatRequest(
            authToken: AuthHelper.get()!,
            inputText: inputText,
            conversationID: Int(currentConversation!.conversationID),
            usePaidModel: GPTModelTierSpecification.paidModels.contains(where: {$0 == currentModel})
        )
        
        // Get stream :) TODO: Need to improve this!
        let stream = ChatWebSocketConnector.getChatStream(request: request)
        
        // So basically how this is going to work is it will create a chat with no text, then it'll update that managed object as new text comes in, then it will save it once all messages are received
        
        /* Insert AI Chat Cell */
        // Create chat and source
        let chat = ChatCDHelper.appendChat(sender: Constants.Chat.Sender.ai, text: "", to: currentConversation!)
        let source = TableViewCellSourceFactory.makeChatTableViewCellSource(from: chat!)
        
        /* Stream! */
        // Create a variable for the entire message
        var fullOutput: String = ""
        
        // Do stream in a Task
        Task {
            // Create null string which may be sent instead of an actual null response from the server
            let nullEquivalentString = "null"
            
            // Call "Finished Loading First Message" flow once when the messages load
            var firstMessage = true
            
            // Previous expected typing label height TODO: Renaming "typing label"?
            var previousExpectedTypingLabelHeight: CGFloat = 0.0
            
            // Important values to get as they come in
            var finishReason: String?
            var conversationID: Int?
            var remaining: Int?
            
            do {
                // Stream the messages to the chat cell
                for try await message in stream {
                    if (firstMessage) {
                        /* Finished Loading First Message */
                        // Do haptic
                        HapticHelper.doLightHaptic()
                        
                        DispatchQueue.main.async {
                            // Stop processing animation (won't "stop again" if already stopped)
                            self.stopProcessingAnimation()
                            
                            // Append the response chat row
                            self.rootView.tableView.appendManagedRow(bySource: source, inSection: self.chatSection, with: .none)
                        }
                        
                        // Set firstChat to false
                        self.firstChat = false
                        
                        // Call inputTextViewOnFinishedGenerating to enable submitButton and cameraButton
                        rootView.inputTextViewOnFinishedGenerating()
                        
                        // Set firstMessage to false so all this is called once!
                        firstMessage = false
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
                    
                    if let gcrConversationID = getChatResponse?.body.conversationID {
                        if gcrConversationID > 0 && conversationID == nil {
                            conversationID = gcrConversationID
                        }
                    }
                    
                    if let gcrRemaining = getChatResponse?.body.remaining {
                        if remaining == nil {
                            remaining = gcrRemaining
                            
                            // Also update the remaining chats text here.. shh TODO: lol
                            updateGeneratedChatsRemaining(remaining: remaining!)
                        }
                    }
                    
                    /* Update Chat Display with Message */
                    
                    DispatchQueue.main.async {
                        // Get expected chat label size with full output
                        if let width = source.typingLabel?.frame.size.width {
                            let expectedTypingLabelSize = NSString(string: fullOutput)
                                .boundingRect(
                                    with: CGSize(width: width, height: .infinity),
                                    options: .usesLineFragmentOrigin,
                                    attributes: [.font: source.typingLabel?.font!],
                                    context: nil
                                )
                            
                            if previousExpectedTypingLabelHeight < expectedTypingLabelSize.height {
                                // Scroll to bottom if already at or near bottom
                                if self.rootView.tableView.isAtBottom(bottomHeightOffset: expectedTypingLabelSize.height - previousExpectedTypingLabelHeight) {
                                    self.rootView.tableView.scrollToBottomUsingOffset(animated: false)
                                }
                            }
                            
                        }
                        
                        print(fullOutput)
                        
                        self.rootView.tableView.beginUpdates()
                        source.typingLabel?.text = fullOutput
                        self.rootView.tableView.endUpdates()
                        
                        // Maybe reload data?
                        //                        self.rootView.tableView.reloadData()
                    }
                }
            } catch {
                // TODO: Are there any errors that would make this function return early? I don't think so right now, I think it's just the error for when the connection is closed which is fine because that means that it has received all the messages
            }
            
            /* Finished Receiving All Messages */
            // Append finish reason text if finish reason is length
            if finishReason == FinishReasons.length && !PremiumHelper.get() {
                fullOutput += Constants.lengthFinishReasonAdditionalText
                
                // TODO: Animate this
                DispatchQueue.main.async {
                    self.rootView.tableView.beginUpdates()
                    source.typingLabel?.text = fullOutput
                    self.rootView.tableView.endUpdates()
                    
                    if let width = source.typingLabel?.frame.size.width {
                        let expectedAdditionalTextSize = NSString(string: Constants.lengthFinishReasonAdditionalText)
                            .boundingRect(
                                with: CGSize(width: width, height: .infinity),
                                options: .usesLineFragmentOrigin,
                                attributes: [.font: source.typingLabel?.font!],
                                context: nil
                            )
                        
                        // TODO: There may have to be an offset here..
                        if self.rootView.tableView.isAtBottom(bottomHeightOffset: expectedAdditionalTextSize.height) {
                            self.rootView.tableView.scrollToBottomUsingOffset(animated: false)
                        }
                    }
                }
            }
            
            // Call inputTextViewOnFinishedTyping to disable softDisable
            rootView.inputTextViewOnFinishedTyping()
            
            // Package and save the complete chat to db
            chat!.text = fullOutput
            try? CDClient.saveContext()
        }
        
        /* Save Chat */
        
        
        
//        // Get chat response
//        ChatRequestHelper.get(inputText: inputText, conversationID: Int(currentConversation!.conversationID), model: currentModel, completion: { responseText, finishReason, conversationID, remaining in
//            // Do haptic
//            HapticHelper.doLightHaptic()
//
//            // Set currentConversation's conversationID and save the current context if conversationID is not nil
//            if conversationID != nil {
//                self.currentConversation!.conversationID = Int64(conversationID!)
//                ConversationCDHelper.saveContext()
//            }
//
//            // Stop the processing animation (won't stop if already stopped)
//            self.stopProcessingAnimation()
//
//            // Trim the firt \n\n off of output if it exists TODO: Do this fix
//            var trimmedResponseText = responseText
//
//            if let firstOccurence = responseText.range(of: "\n\n") {
//                trimmedResponseText.removeSubrange(responseText.startIndex..<firstOccurence.upperBound)
//            }
//
//            // Append length finish reason additional text if finish reason is length
//            if finishReason == FinishReasons.length && !PremiumHelper.get() {
//                trimmedResponseText += Constants.lengthFinishReasonAdditionalText
//            }
//
//            // Update remaining text and instance variable
//            self.updateGeneratedChatsRemaining(remaining: remaining)
//
//            // Set firstChat to false
//            self.firstChat = false
//
//            // Add response chat
//            self.addChat(message: trimmedResponseText, sender: Constants.Chat.Sender.ai)
//
//            // Call inputTextViewOnFinishedGenerating to enable submitButton and cameraButton
//            self.rootView.inputTextViewOnFinishedGenerating()
//
//            // Enable submit and camera button and show review prompt at frequency for premium users and stop soft disable, show ad at frequency, and present limit reached alert if needed for free users
//            if PremiumHelper.get() {
//                self.showReviewAtFrequency()
//            } else {
//                self.showAdAtFrequency()
//
//                if finishReason == FinishReasons.limit {
//                    let ac = UIAlertController(title: "Limit Reached", message: "You've reached your daily chat limit. Upgrade for unlimited chats...", preferredStyle: .alert)
//                    ac.addAction(UIAlertAction(title: "Close", style: .cancel))
//                    ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
//                        self.goToUltraPurchase()
//                    }))
//
//                    DispatchQueue.main.async {
//                        self.present(ac, animated: true)
//                    }
//                }
//            }
//        })
    }
    
    func showFirstConversationChats() {
        // Load first chats if there are no chats
        if currentConversation!.chats!.count == 0 {
            self.addChat(message: "Hi! I'm Prof. Write, your AI writing companion...", sender: Constants.Chat.Sender.ai)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (!UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? 2.4 : 2.0), execute: {
                self.addChat(message: "Ask me to write lyrics, poems, essays and more. Talk to me like a human and ask me anything you'd ask your professor!", sender: Constants.Chat.Sender.ai)
                DispatchQueue.main.asyncAfter(deadline: .now() + (!UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? 5.2 : 4.0), execute: {
                    self.addChat(message: "I do better with more detail. Don't say, \"Essay on Belgium,\" say \"200 word essay on Belgium's cultural advances in the past 20 years.\" Remember, I'm your Professor, so use what I write as inspiration and never plagiarize!", sender: Constants.Chat.Sender.ai)
                })
            })
        }
    }
    
    func showReviewAtFrequency() {
        if currentConversation!.chats!.count % Constants.reviewFrequency == 0 && !firstChat {
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
    
    func startProcessingAnimation() {
        if !isProcessingChat {
            isProcessingChat = true
            
            // Do these on main thread
            DispatchQueue.main.async {
                // Save if should scroll and insert loading row
                let shouldScroll = self.rootView.tableView.isAtBottom()//self.rootView.tableView.isAtBottom(bottomHeightOffset: (self.rootView.tableView.cellForRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.chatSection) - 1, section: self.chatSection))?.frame.height ?? 0) + 40.0)
                
                // Insert loading cell source
                self.rootView.tableView.insertManagedRow(bySource: LoadingChatTableViewCellSource(), at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.chatSection), section: self.chatSection), with: .none)
                
                // Do scroll!
                if shouldScroll {
                    self.rootView.tableView.scrollToBottomUsingOffset(animated: false)
//                    self.rootView.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false) // TODO: - Do scrolling queue or something
                }
            }
        }
    }
    
    func stopProcessingAnimation() {
        if isProcessingChat {
            isProcessingChat = false
            
            // Delete loading row
            self.rootView.tableView.deleteManagedRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.chatSection) - 1, section: self.chatSection), with: .none)
        }
    }
    
    func addChat(message: String, sender: String) {
        // Create chat and source
        let chat = ChatCDHelper.appendChat(sender: sender, text: message, to: currentConversation!)
        let source = TableViewCellSourceFactory.makeChatTableViewCellSource(from: chat!)
        
        // Don't animate insertion if the previous row was a loading row, meaning the sender was ai TODO: Or should it just be not the user?
        var animation = UITableView.RowAnimation.automatic
        if !isProcessingChat && sender == Constants.Chat.Sender.ai {
            animation = .none
        }
        
//        // Try to scroll to bottom
//        DispatchQueue.main.async {
//            let height = self.rootView.tableView.cellForRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.chatSection) - 1, section: self.chatSection))!.frame.size.height
//            if self.rootView.tableView.isAtBottom(bottomHeightOffset: height) {
////                self.rootView.tableView.scrollToBottom(animated: false)
//                self.rootView.tableView.contentOffset.y += height
//            }
//        }
        
        // Create and start a new Typewriter for the AI response
        if sender == Constants.Chat.Sender.ai {
            var prevExpectedHeight: CGFloat = 0
            let timeInterval = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? Constants.premiumTypingTimeInterval : Constants.freeTypingTimeInterval
            let typewriter = Typewriter.start(text: chat!.text!, timeInterval: timeInterval, typingUpdateLetterCount: chat!.text!.count/Constants.defaultTypingUpdateLetterCountFactor + 1, block: { typewriter, currentText in
                DispatchQueue.main.async {
                    // One more tick after it is invalidated (suspended)
                    if !typewriter.isValid() {
                        // Call inputTextViewOnFinishedTyping to disable softDisable
                        self.rootView.inputTextViewOnFinishedTyping()
                        
                        // TODO: - Is this a good place for this, especially for preimum if there are multiple chats filling?
                    }
                    
                    // Try to scroll if content height has increased and at bottom TODO: - Is this cool to do if there are multiple filling at once? What if there is some sort of future update?
                    if source.typingLabel != nil {
                        let expectedTypingLabelSize = NSString(string: currentText).boundingRect(
                            with: CGSize(width: source.typingLabel!.frame.size.width, height: .infinity),
                            options: .usesLineFragmentOrigin,
                            attributes: [.font: source.typingLabel!.font!],
                            context: nil)
                        if prevExpectedHeight < expectedTypingLabelSize.height {
                            // Reload for size enlargement
//                            self.rootView.tableView.reloadData()
                            
                            if self.rootView.tableView.isAtBottom(bottomHeightOffset: prevExpectedHeight) {
                                self.rootView.tableView.scrollToBottomUsingOffset(animated: false)
                            }
                            
                            // Reload for size enlargement
                            self.rootView.tableView.reloadData()
                            
                            prevExpectedHeight = expectedTypingLabelSize.height
                        }
                    }
                    
                    // Update the label in the tableView!
                    source.typingLabel?.text = currentText
                }
            })
            
            source.typewriter = typewriter
        }
        
        // Do scrolling and insertion on main thread
        DispatchQueue.main.async {
            // Save if user should scroll if tableView is at (or near) the bottom
            let shouldScroll = self.rootView.tableView.isAtBottom()
            
            // Insert row and append created source to chatRowSources!
            self.rootView.tableView.appendManagedRow(bySource: source, inSection: self.chatSection, with: animation)
            
            // Get calculated height of last cell if it is loaded and scroll to bottom if within the height of the last cell, and just don't mind scrolling if the last one isn't loaded beacuse it means that the user is not close enough to the bottom anyways :)
            if let height = self.rootView.tableView.cellForRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.chatSection) - 1, section: self.chatSection))?.frame.size.height {
                if self.rootView.tableView.isAtBottom(bottomHeightOffset: height) {
                    self.rootView.tableView.scrollToBottomUsingOffset(animated: false)
                    //                self.rootView.tableView.contentOffset.y += height
                }
            }
            
            // Do the scroll if the user was at the bottom of the tableView before the insertion
//            if shouldScroll {
//                self.rootView.tableView.scrollToBottomRow(animated: false)
////                self.rootView.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
//            }
        }
    }
    
    func dismissKeyboard() {
        // Move the view down faster than the keyboard
        UIView.animate(withDuration: 0.11, delay: 0.0, options: .curveEaseInOut, animations: {
            if self.view.frame.origin.y != self.origin {
                self.view.frame.origin.y = self.origin
            }
        })
        
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

