//
//  MainViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import UIKit
import StoreKit
import GoogleMobileAds

class ChatViewController: UIViewController {
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var tableView: ChatTableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var promoView: RoundedView!
    @IBOutlet weak var promoShadowView: ShadowView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var remainingView: RoundedView!
    @IBOutlet weak var remainingShadowView: ShadowView!
    @IBOutlet weak var chatsRemainingText: UILabel!
    @IBOutlet weak var upgradeNowText: UILabel!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adShadowView: ShadowView!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var inputBackgroundView: RoundedView!
    
    @IBOutlet weak var adViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var promoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var submitButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButtonCenterYConstraint: NSLayoutConstraint!
    
    let promoViewHeightConstraintConstant = 50.0
    
    let inputPlaceholder = "Tap to start chatting..."
    
    let chatSection = 0
    let spacerSection = 1
    
    let chatTableViewManager: ChatTableViewManagerProtocol = ChatTableViewManager()
    
//    var chatRowSources: [[UITableViewCellSource]] = [[]]
    
    var origin: CGFloat = 0.0
    
    var moreMenuBarItem = UIBarButtonItem()
    var shareMenuBarItem = UIBarButtonItem()
    var proMenuBarItem = UIBarButtonItem()
    var navigationSpacer = UIBarButtonItem()
    
    var shouldShowUltra = true
    var shouldScroll = true
    var firstChat = true
    var isProcessingChat = false
    var submitSoftDisable = false
    var isLongPressForShare = false
    
    var remaining = -1
    var timeInterval = Constants.freeTypingTimeInterval
    
    var interstitial: GADInterstitialAd?
    var banner: GADBannerView!
    var failedToLoadInterstitial = false
    
    var cameraButtonHeightConstraintSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For Testing
        //        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "417bf2ca112515b09c600668985dbf2b" ]
        
        /* Setup Delegates */
        inputTextView.delegate = self
        tableView.manager = chatTableViewManager
        
        /* Set TableView touchDelegate */
        tableView.touchDelegate = self
        
        /* Setup ChatCell Nibs TODO: Should this just be in ChatTableView? How can this be dynamic? */
        RegistryHelper.register(Registry.View.TableView.Chat.Cells.user, to: tableView)
        RegistryHelper.register(Registry.View.TableView.Chat.Cells.ai, to: tableView)
        RegistryHelper.register(Registry.View.TableView.Chat.Cells.padding, to: tableView)
        RegistryHelper.register(Registry.View.TableView.Chat.Cells.loading, to: tableView)
        
        /* Setup UI Stuff */
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        
        submitButton.isEnabled = false
        cameraButton.isEnabled = true
        
        // Setup "placeholder" for TextView
        inputTextView.text = inputPlaceholder
        inputTextView.textColor = .lightText
        
        // Setup Keyboard Stuff
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Dismiss Keyboard Gesture Recognizer
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
        
        // Tap on Remaining View to upgrade gesture recognizer
        remainingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upgradeSelector)))
        
        // Long press for message share sheet
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnTableView))
        longPressGestureRecognizer.cancelsTouchesInView = false
        longPressGestureRecognizer.minimumPressDuration = 1.0
        tableView.addGestureRecognizer(longPressGestureRecognizer)
        
        if UserDefaults.standard.string(forKey: Constants.authTokenKey) == nil {
            HTTPSHelper.registerUser(delegate: self)
        } else {
            HTTPSHelper.getRemaining(delegate: self, authToken: UserDefaults.standard.string(forKey: Constants.authTokenKey)!)
        }
        
        // Setup ad view and ads
        interstitial?.fullScreenContentDelegate = self
        
        adView.alpha = 0.0
        adViewHeightConstraint.constant = 0.0
        
        banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = Private.bannerID
        banner.rootViewController = self
        banner.delegate = self
        
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            banner.load(GADRequest())
            loadGAD()
        }
        
        // Set up cell source at index 0
        let allChats = ChatStorageHelper.getAllChats()
        chatTableViewManager.chatRowSources.insert(ChatTableViewCellSourceMaker.makeChatTableViewCellSourceArray(fromChatObjectArray: allChats), at: chatSection)
        
        // Set up default tiered padding source at index 1 in spacerSection
        chatTableViewManager.chatRowSources.insert([TieredPaddingTableViewCellSource()], at: spacerSection)
        
        
        // Initial updates
        updateInputTextViewSize(textView: inputTextView)
        updateTextViewSubmitButtonEnabled(textView: inputTextView)
        
        loadMenuBarItems()
        setLeftMenuBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        doServerPremiumCheck()
        setPremiumItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if shouldScroll {
            DispatchQueue.main.async{
                self.tableView.reallyScrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Call setPremiumItems again, so that it will be called when the Premium window is closed. Redundant, can fix. Must also be called in viewWillAppear to limit jerky UI changes.
        setPremiumItems()
        
        // Set origin for keyboard
        origin = self.view.frame.origin.y
        
        // Set the camera button constraints
        if !cameraButtonHeightConstraintSet && inputTextView.text == inputPlaceholder {
            cameraButtonHeightConstraint.constant = inputBackgroundView.frame.height
            
            cameraButtonHeightConstraintSet = true
        }
        
        // Show Ultra Purchase on launch if not premium
        if shouldShowUltra && !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            shouldShowUltra = false
            goToUltraPurchase()
        }
        
        // Load first chats if there are no chats
        if ChatStorageHelper.getAllChats().count == 0 {
            addChat(message: "Hi! I'm Prof. Write, your AI writing companion...", userSent: .ai)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (!UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? 1.7 : 1.0), execute: {
                self.addChat(message: "Ask me to write lyrics, poems, essays and more. Talk to me like a human and ask me anything you'd ask your professor!", userSent: .ai)
                DispatchQueue.main.asyncAfter(deadline: .now() + (!UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? 3.2 : 1.4), execute: {
                    self.addChat(message: "I do better with more detail. Don't say, \"Essay on Belgium,\" say \"200 word essay on Belgium's cultural advances in the past 20 years.\" Remember, I'm your Professor, so use what I write as inspiration and never plagiarize!", userSent: .ai)
                })
            })
        }
        
        // Redundant
        doServerPremiumCheck()
    }
    
    @IBAction func submitButton(_ sender: Any) {
        dismissKeyboard()
        
        if submitSoftDisable {
            let alert = UIAlertController(title: "3 Days Free", message: "Send messages faster! Try Ultra for 3 days free today.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Try Now", style: .default, handler: { action in
                self.goToUltraPurchase()
            }))
            present(alert, animated: true)
            return
        }
        
        guard let authToken = UserDefaults.standard.string(forKey: Constants.authTokenKey) else {
            HTTPSHelper.registerUser(delegate: self)
            return
        }
        
        //Button is disabled until response for premium
        //Button is enabled BUT shows a popup when pressed
        if UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            submitButton.isEnabled = false
            cameraButton.isEnabled = false
        } else {
            softDisable()
        }
        
        HTTPSHelper.getChat(delegate: self, authToken: authToken, inputText: inputTextView.text)
        addChat(message: inputTextView.text, userSent: .user)
        
        // Set inputTextView to placeholder and update its size
        inputTextView.text = inputPlaceholder
        inputTextView.textColor = .lightText //TODO: - Make this a constant
        updateInputTextViewSize(textView: inputTextView)
        
        // Start processing animation
        startProcessingAnimation()
        
        // Show Ad if Not Premium
        loadGAD()
    }
    
    @IBAction func promoButton(_ sender: Any) {
        goToUltraPurchase()
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        dismissKeyboard()
        
        if submitSoftDisable {
            let alert = UIAlertController(title: "3 Days Free", message: "Scan while chats are typing! Try Ultra for 3 days free today.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Try Now", style: .default, handler: { action in
                self.goToUltraPurchase()
            }))
            present(alert, animated: true)
            return
        }
        
        performSegue(withIdentifier: "toPictureView", sender: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Delay the movement by a fraction to avoid a black box since it goes up quicker now
            UIView.animate(withDuration: 0.11, delay: 0.05, options: .curveEaseInOut, animations: {
                if self.view.frame.origin.y == self.origin {
                    //TODO: - In the previous version, the -tabBarController.tabBar.frame.size.height wasn't necessary, but now it is otherwise a black box the size of the tabBar will show up
                    self.view.frame.origin.y -= (keyboardSize.height - self.tabBarController!.tabBar.frame.size.height)
                }
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
    }
    
    @objc func dismissKeyboard() {
        // Move the view down faster than the keyboard
        UIView.animate(withDuration: 0.11, delay: 0.0, options: .curveEaseInOut, animations: {
            if self.view.frame.origin.y != self.origin {
                self.view.frame.origin.y = self.origin
            }
        })
        
        view.endEditing(true)
    }
    
    @objc func openMenu() {
        performSegue(withIdentifier: "toSettingsView", sender: nil)
    }
    
    @objc func shareApp() {
        let activityVC = UIActivityViewController(activityItems: [UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) ?? ""], applicationActivities: [])
        
        present(activityVC, animated: true)
    }
    
    @objc func ultraPressed() {
        goToUltraPurchase()
    }
    
    @objc func upgradeSelector(notification: NSNotification) {
        goToUltraPurchase()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPictureView" {
            if let detailVC = segue.destination as? CameraViewController {
                detailVC.delegate = self
            }
        }
    }
    
    @objc func longPressOnTableView(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)
        
        if indexPath != nil && gestureRecognizer.state == .began {
            // Get the cell tapped
            let cell = tableView.cellForRow(at: indexPath!) as! ChatTableViewCell
            
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
            
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: [])
            
            present(activityVC, animated: true)
            
            // Unbounce cell since it is a ChatTableViewCell which is always Bounceable
            cell.endBounce()
        }
    }
    
    func loadMenuBarItems() {
        /* Setup Navigation Bar Appearance (mmake it solid) */
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.topBarBackgroundColor
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        /* Setup Menu Menu Bar Item */
        let moreImage = UIImage(systemName: "line.3.horizontal")
        let moreImageButton = UIButton(type: .custom)
        
        moreImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        moreImageButton.setBackgroundImage(moreImage, for: .normal)
        moreImageButton.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        moreImageButton.tintColor = Colors.elementTextColor
        
        moreMenuBarItem = UIBarButtonItem(customView: moreImageButton)
        
        /* Setup Share Menu Bar Item */
        let shareImage = UIImage(named: "shareImage")?.withTintColor(Colors.elementTextColor)
        let shareImageButton = UIButton(type: .custom)
        
        shareImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        shareImageButton.setBackgroundImage(shareImage, for: .normal)
        shareImageButton.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
        shareImageButton.tintColor = Colors.elementTextColor
        
        shareMenuBarItem = UIBarButtonItem(customView: shareImageButton)
        
        /* Setup Pro Menu Bar Item */
        //TODO: - New Pro Image
        let proImage = UIImage.gifImageWithName("giftGif")
        let proImageButton = RoundedButton(type: .custom)
        proImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        proImageButton.tintColor = Colors.elementTextColor
        proImageButton.setImage(proImage, for: .normal)
        proImageButton.addTarget(self, action: #selector(ultraPressed), for: .touchUpInside)
        
        proMenuBarItem = UIBarButtonItem(customView: proImageButton)
        
        /* Setup Navigation Spacer */
        navigationSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigationSpacer.width = 14
        
        /* Setup More */
        moreMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
        moreMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        /* Setup Share */
        shareMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
        shareMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        /* Setup Constraints */
        
        proMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 34).isActive = true
        proMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 140, height: 80))
        imageView.contentMode = .scaleAspectFit
        
        // Setup logoImage
        let image = UIImage(named: "logoImage")
        imageView.image = image
        imageView.tintColor = Colors.elementTextColor
        navigationItem.titleView = imageView
    }
    
    func setLeftMenuBarItems() {
        /* Put things in Left NavigationBar. Phew! */
        navigationItem.leftBarButtonItems = [moreMenuBarItem, shareMenuBarItem, navigationSpacer]
        
    }
    
    func setPremiumItems() {
        /* Update the text that says how many chats are remaining for user */
        updateRemainingText()
        
        /* Setup Right Bar Button Items and Top Ad View */
        var rightBarButtonItems:[UIBarButtonItem] = []
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            rightBarButtonItems.append(proMenuBarItem)
        } else {
            adView.alpha = 0.0
            adViewHeightConstraint.constant = 0.0
            adShadowView.isHidden = true
        }
        
        /* Put things in Right NavigationBar */
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        /* Update the tabView with correct image and button */
        // Fix this and make it better lol
        let tabBarItemIndex = (tabBarController?.tabBar.items?.count ?? 0) - 1
        
        if tabBarItemIndex < 0 {
            print("Tab bar index is less than zero...")
            return
        }
        
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            tabBarController?.tabBar.items![tabBarItemIndex].image = UIImage(named: Constants.premiumBottomButtonNotSelectedImageName)
        } else {
            tabBarController?.tabBar.items![tabBarItemIndex].image = UIImage(named: Constants.shareBottomButtonNotSelectedImageName)
        }
        
        /* If user just became premium, or the opposite, recalculate cell height */
        //TODO: - Make a separate function for only things that need to be recalculated/redone when user immediately purchases premium
        
    }
    
    func goToUltraPurchase() {
        performSegue(withIdentifier: "toUltraPurchase", sender: nil)
    }
    
    func softEnable() {
        self.submitButton.alpha = 1.0
        self.cameraButton.alpha = 1.0
        self.submitSoftDisable = false
    }
    
    func softDisable() {
        self.submitButton.alpha = 0.8
        self.cameraButton.alpha = 0.8
        self.submitSoftDisable = true
    }
    
    func startProcessingAnimation() {
        if !isProcessingChat {
            isProcessingChat = true
            
            // Save if should scroll and insert loading row
            let shouldScroll = tableView.isAtBottom(bottomHeightOffset: (tableView.cellForRow(at: IndexPath(row: tableView.numberOfRows(inSection: chatSection) - 1, section: chatSection))?.frame.height ?? 0) + 40.0)
            
            tableView.insertManagedRow(bySource: LoadingTableViewCellSource(), at: IndexPath(row: tableView.numberOfRows(inSection: chatSection), section: chatSection), with: .none)
            
            // Do scroll!
            if shouldScroll {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false) // TODO: - Do scrolling queue or something
            }
        }
    }
    
    func stopProcessingAnimation() {
        if isProcessingChat {
            isProcessingChat = false
            
            tableView.deleteManagedRow(at: IndexPath(row: tableView.numberOfRows(inSection: chatSection) - 1, section: chatSection), with: .none)
        }
    }
    
    func addChat(message: String, userSent: ChatSender) {
        // Create chatObject and chatTableViewCellSource
        let chatObject = ChatObject(text: message, sender: userSent)
        var source = ChatTableViewCellSource(chat: chatObject)
        
        // Append the chat to CoreData or UserDefaults or whatever I use rn TODO: Convert to CoreData!
        ChatStorageHelper.appendChat(chatObject: chatObject)
        
        // Don't animate insertion if the previous row was a loading row
        var animation = UITableView.RowAnimation.automatic
        if !isProcessingChat && userSent == .ai {
            animation = .none
        }
        
        // Save if user should scroll if tableView is at (or near) the bottom
        let shouldScroll = tableView.isAtBottom()
        
        // Create and start a new Typewriter for the AI response
        if userSent == .ai {
            var prevExpectedHeight: CGFloat = 0
            let timeInterval = UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) ? Constants.premiumTypingTimeInterval : Constants.freeTypingTimeInterval
            let typewriter = Typewriter.start(text: chatObject.text, timeInterval: timeInterval, typingUpdateLetterCount: chatObject.text.count/Constants.defaultTypingUpdateLetterCountFactor + 1, block: { typewriter, currentText in
                DispatchQueue.main.async {
                    // One more tick after it is invalidated (suspended)
                    if !typewriter.isValid() {
                        self.softEnable()
                        
                        // TODO: - Is this a good place for this, especially for preimum if there are multiple chats filling?
                    }
                    
                    // Try to scroll if content height has increased and at bottom TODO: - Is this cool to do if there are multiple filling at once? What if there is some sort of future update?
                    let expectedTypingLabelSize = NSString(string: currentText).boundingRect(
                        with: CGSize(width: source.typingLabel!.frame.size.width, height: .infinity),
                        options: .usesLineFragmentOrigin,
                        attributes: [.font: source.typingLabel!.font!],
                        context: nil)
                    if prevExpectedHeight < expectedTypingLabelSize.height {
                        // Reload for size enlargement
                        self.tableView.reloadData()
                        
                        if self.tableView.isAtBottom() {
                            self.tableView.reallyScrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
                        }
                        
                        prevExpectedHeight = expectedTypingLabelSize.height
                    }
                    
                    // Update the label in the tableView!
                    source.typingLabel?.text = currentText
                    
//                    self.tableView.reloadData() // TODO: - Reload data at
                }
            })
            
            source.typewriter = typewriter
        }
        
        // Insert row and append created source to chatRowSources!
        tableView.appendManagedRow(bySource: source, inSection: chatSection, with: animation)
        
        // Do the scroll if the user was at the bottom of the tableView before the insertion
        if shouldScroll {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
        }
    }
    
    func updateRemainingText() {
        DispatchQueue.main.async {
            if UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                self.remainingView.isHidden = true
                self.remainingShadowView.isHidden = true
                self.promoView.isHidden = true
                self.promoShadowView.isHidden = true
                
                self.promoViewHeightConstraint.constant = 0.0
            } else {
                self.remainingView.isHidden = false
                self.remainingShadowView.isHidden = false
                self.promoView.isHidden = false
                self.promoShadowView.isHidden = false
                
                self.promoViewHeightConstraint.constant = self.promoViewHeightConstraintConstant
                
                self.chatsRemainingText.text = "You have \(self.remaining < 0 ? 0 : self.remaining) chat\(self.remaining == 1 ? "" : "s") remaining today..."
            }
        }
    }
    
    func updateTextViewSubmitButtonEnabled(textView: UITextView) {
        if textView.text == "" || textView.textColor == .lightText || textView.text == inputPlaceholder  {
            submitButton.isEnabled = false
        } else {
            submitButton.isEnabled = true
        }
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

