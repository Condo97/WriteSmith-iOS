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
    
    let sourcedTableViewManager: SourcedTableViewManagerProtocol = SourcedTableViewManager()
    
    // Instance variables
    var origin: CGFloat = 0.0
    
    var shouldScroll = true
    var firstChat = true
    var isProcessingChat = false
    var isLongPressForShare = false
    
    var remaining = -1
    
    var cameraButtonHeightConstraintSet = false
    
    var timeInterval = Constants.freeTypingTimeInterval
    
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
        
        // Setup ad view and ads
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
        sourcedTableViewManager.sources.insert([TieredPaddingTableViewCellSource()], at: spacerSection)
        
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
        
        if shouldScroll {
            DispatchQueue.main.async{
                self.rootView.tableView.reallyScrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
            }
        }
        
        // Set the camera button constraints
        if !cameraButtonHeightConstraintSet && rootView.isBlankWithPlaceholder {
            rootView.cameraButtonHeightConstraint.constant = rootView.inputBackgroundView.frame.height
            
            cameraButtonHeightConstraintSet = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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

            // Set adView visibility if premium
            if isPremium {
                self.rootView.adView.alpha = 0.0
                self.rootView.adViewHeightConstraint.constant = 0.0
                self.rootView.adShadowView.isHidden = true
            }
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
        
        // Set as first rightBarButtonItem
        navigationItem.rightBarButtonItems?.insert(plusBarButtonItem, at: 0)
    }
    
    override func openMenu() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
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
        if rootView.hitTest(sender.location(in: self.view), with: nil) == rootView.submitButton  {
            return
        }
        
        dismissKeyboard()
    }
    
    @objc func upgradeSelector(notification: NSNotification) {
        UltraViewControllerPresenter.presentOnTop(animated: true)
    }
    
    @objc func longPressOnTableView(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: rootView.tableView)
        let indexPath = rootView.tableView.indexPathForRow(at: location)
        
        if indexPath != nil && gestureRecognizer.state == .began {
            // Get the cell tapped
            let cell = rootView.tableView.cellForRow(at: indexPath!) as! ChatBubbleTableViewCell
            
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
        delegate?.popAndPushToNewConversation()
    }
    
    func generateChat(inputText: String) {
        // Add user's chat
        addChat(message: inputText, sender: Constants.Chat.Sender.user)
        
        // Start processing animation
        startProcessingAnimation()
        
        // Show Ad if Not Premium
        loadGAD()
        
        // Get chat response
        ChatRequestHelper.get(inputText: inputText, conversationID: Int(currentConversation!.conversationID), completion: { responseText, finishReason, conversationID, remaining in
            // Set currentConversation's conversationID and save the current context if conversationID is not nil
            if conversationID != nil {
                self.currentConversation!.conversationID = Int64(conversationID!)
                ConversationCDHelper.saveContext()
            }
            
            // Stop the processing animation (won't stop if already stopped)
            self.stopProcessingAnimation()
            
            // Trim the firt \n\n off of output if it exists TODO: Do this fix
            var trimmedResponseText = responseText
            
            if let firstOccurence = responseText.range(of: "\n\n") {
                trimmedResponseText.removeSubrange(responseText.startIndex..<firstOccurence.upperBound)
            }
            
            // Append length finish reason additional text if finish reason is length
            if finishReason == FinishReasons.length && !PremiumHelper.get() {
                trimmedResponseText += Constants.lengthFinishReasonAdditionalText
            }
            
            // Update remaining text and instance variable
            self.updateGeneratedChatsRemaining(remaining: remaining)
            
            // Set firstChat to false
            self.firstChat = false
            
            // Add response chat
            self.addChat(message: trimmedResponseText, sender: Constants.Chat.Sender.ai)
            
            // Call inputTextViewOnFinishedGenerating to enable submitButton and cameraButton
            self.rootView.inputTextViewOnFinishedGenerating()
            
            // Enable submit and camera button and show review prompt at frequency for premium users and stop soft disable, show ad at frequency, and present limit reached alert if needed for free users
            if PremiumHelper.get() {
                self.showReviewAtFrequency()
            } else {
                self.showAdAtFrequency()
                
                if finishReason == FinishReasons.limit {
                    let ac = UIAlertController(title: "Limit Reached", message: "You've reached your daily chat limit. Upgrade for unlimited chats...", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Close", style: .cancel))
                    ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
                        self.goToUltraPurchase()
                    }))
                    
                    DispatchQueue.main.async {
                        self.present(ac, animated: true)
                    }
                }
            }
        })
    }
    
    func showFirstConversationChats() {
        // Load first chats if there are no chats
        if currentConversation!.chats!.count == 0 {
            self.addChat(message: "Hi! I'm Prof. Write, your AI writing companion...", sender: Constants.Chat.Sender.ai)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (!UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? 2.4 : 1.0), execute: {
                self.addChat(message: "Ask me to write lyrics, poems, essays and more. Talk to me like a human and ask me anything you'd ask your professor!", sender: Constants.Chat.Sender.ai)
                DispatchQueue.main.asyncAfter(deadline: .now() + (!UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? 5.2 : 1.4), execute: {
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
    
    func showAdAtFrequency() {
        if self.remaining % Constants.adFrequency == 0  && self.remaining != 0 && !self.firstChat {
            if self.interstitial != nil {
                //Display ad
                DispatchQueue.main.async {
                    self.interstitial?.present(fromRootViewController: self)
                }
            } else {
                // Load if interstitial is nil
                loadGAD()
            }
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
                let shouldScroll = self.rootView.tableView.isAtBottom(bottomHeightOffset: (self.rootView.tableView.cellForRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.chatSection) - 1, section: self.chatSection))?.frame.height ?? 0) + 40.0)
                
                // Insert loading cell source
                self.rootView.tableView.insertManagedRow(bySource: LoadingChatTableViewCellSource(), at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.chatSection), section: self.chatSection), with: .none)
                
                // Do scroll!
                if shouldScroll {
                    self.rootView.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false) // TODO: - Do scrolling queue or something
                }
            }
        }
    }
    
    func stopProcessingAnimation() {
        if isProcessingChat {
            isProcessingChat = false
            
            // Delete loading row on main queue
            DispatchQueue.main.async {
                self.rootView.tableView.deleteManagedRow(at: IndexPath(row: self.rootView.tableView.numberOfRows(inSection: self.chatSection) - 1, section: self.chatSection), with: .none)
            }
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
                            self.rootView.tableView.reloadData()
                            
                            if self.rootView.tableView.isAtBottom() {
                                self.rootView.tableView.reallyScrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
                            }
                            
                            prevExpectedHeight = expectedTypingLabelSize.height
                        }
                    }
                    
                    // Update the label in the tableView!
                    source.typingLabel?.text = currentText
                    
//                    self.rootView.tableView.reloadData() // TODO: - Reload data at
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
            
            // Do the scroll if the user was at the bottom of the tableView before the insertion
            if shouldScroll {
                self.rootView.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
            }
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
    
}

