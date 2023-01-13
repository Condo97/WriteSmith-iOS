//
//  MainViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import UIKit
import StoreKit
import GoogleMobileAds

class MainViewController: UIViewController {
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var promoView: RoundedView!
    @IBOutlet weak var promoShadowView: ShadowView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var remainingView: RoundedView!
    @IBOutlet weak var remainingShadowView: ShadowView!
    @IBOutlet weak var chatsRemainingText: UILabel!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adShadowView: ShadowView!
    
    @IBOutlet weak var adViewHeightConstraint: NSLayoutConstraint!
    
    let inputPlaceholder = "Tap to start chatting..."
    
    var rowsToType: [Int] = []
    var origin: CGFloat = 0.0
    
    var logoMenuBarItem = UIBarButtonItem()
    var moreMenuBarItem = UIBarButtonItem()
    var shareMenuBarItem = UIBarButtonItem()
    var proMenuBarItem = UIBarButtonItem()
    var navigationSpacer = UIBarButtonItem()
    
    var firstLoad = false
    var firstChat = true
    var isProcessingChat = false
    var submitSoftDisable = false
    
    var remaining = -1
    
    var interstitial: GADRewardedInterstitialAd?
    var banner: GADBannerView!
    var failedToLoadInterstitial = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For Testing
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "417bf2ca112515b09c600668985dbf2b" ]
        
        inputTextView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        interstitial?.fullScreenContentDelegate = self
        
        adViewHeightConstraint.constant = 0.0
        
        banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = Private.bannerID
        banner.rootViewController = self
        banner.delegate = self
        
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            banner.load(GADRequest())
            loadGAD()
        }
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        
        submitButton.isEnabled = false
        
        // Setup "placeholder" for TextView
        inputTextView.text = inputPlaceholder
        inputTextView.textColor = .lightGray
        
        // Setup Navigation Bar Appearance (mmake it solid)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.accentColor
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        // Setup Keyboard Stuff
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)))
        remainingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upgradeSelector)))
        
        if UserDefaults.standard.string(forKey: Constants.authTokenKey) == nil {
            HTTPSHelper.registerUser(delegate: self)
        } else {
            HTTPSHelper.getRemaining(delegate: self, authToken: UserDefaults.standard.string(forKey: Constants.authTokenKey)!)
        }
        
        updateInputTextViewSize(textView: inputTextView)
        
        loadMenuBarItems()
        setLeftMenuBarItems()
        setPremiumItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstLoad && !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            firstLoad = false
            goToUltraPurchase()
        }
        
        doServerPremiumCheck()
        setPremiumItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
        
        origin = self.view.frame.origin.y
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
        } else {
            DispatchQueue.main.async {
                self.submitButton.alpha = 0.8
                self.submitSoftDisable = true
            }
        }
        
        HTTPSHelper.getChat(delegate: self, authToken: authToken, inputText: inputTextView.text)
        addChat(message: inputTextView.text, userSent: .user)
        inputTextView.text = ""
        updateInputTextViewSize(textView: inputTextView)
        
        if !isProcessingChat {
            isProcessingChat = true
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    @IBAction func promoButton(_ sender: Any) {
        goToUltraPurchase()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == origin {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != origin {
            self.view.frame.origin.y = origin
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func openMenu() {
        performSegue(withIdentifier: "toSettingsView", sender: nil)
    }
    
    @objc func shareApp() {
        let activityVC = UIActivityViewController(activityItems: [Constants.shareURL], applicationActivities: [])
        
        present(activityVC, animated: true)
    }
    
    @objc func ultraPressed() {
        goToUltraPurchase()
    }
    
    @objc func upgradeSelector(notification: NSNotification) {
        goToUltraPurchase()
    }
    
    func loadMenuBarItems() {
        /* Setup Logo Menu Bar Item */
        let logoImage = UIImage(named: "logoImage")
        let logoImageButton = UIButton(type: .custom)
        
        logoImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 30)
        logoImageButton.setBackgroundImage(logoImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        //logoImageButton.addTarget(self, action: #selector(doSomethingFunny), for: .touchUpInside) //Can add this for an extra way to advertise or something? Maybe shares?
        logoImageButton.tintColor = Colors.chatTextColor
        
        logoMenuBarItem = UIBarButtonItem(customView: logoImageButton)
        
        /* Setup Menu Menu Bar Item */
        let moreImage = UIImage(systemName: "line.3.horizontal")
        let moreImageButton = UIButton(type: .custom)
        
        moreImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        moreImageButton.setBackgroundImage(moreImage, for: .normal)
        moreImageButton.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        moreImageButton.tintColor = Colors.chatTextColor
        
        moreMenuBarItem = UIBarButtonItem(customView: moreImageButton)
        
        /* Setup Share Menu Bar Item */
        let shareImage = UIImage.gifImageWithName("shareImage")
        let shareImageButton = UIButton(type: .custom)
        
        shareImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        shareImageButton.setBackgroundImage(shareImage, for: .normal)
        shareImageButton.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
        shareImageButton.tintColor = Colors.chatTextColor
        
        shareMenuBarItem = UIBarButtonItem(customView: shareImageButton)
        
        
        /* Setup Pro Menu Bar Item */
        //TODO: - New Pro Image
        let proImage = UIImage.gifImageWithName("giftGif")
        let proImageButton = RoundedButton(type: .custom)
        proImageButton.borderWidth = 2.0
        proImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        proImageButton.tintColor = Colors.chatTextColor
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
        logoMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 86).isActive = true
        logoMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        proMenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 34).isActive = true
        proMenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 170, height: 80))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "logoImage")
        imageView.image = image
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
            adViewHeightConstraint.constant = 0.0
            adShadowView.isHidden = true
        }
        
        /* Put things in Right NavigationBar */
        navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
    func goToUltraPurchase() {
        performSegue(withIdentifier: "toUltraPurchase", sender: nil)
    }
    
    func addChat(message: String, userSent: ChatSender) {
        ChatStorageHelper.appendChat(chatObject: ChatObject(text: message, userSent: userSent))
        
        let row = ChatStorageHelper.getAllChats().count - 1
        var animation = UITableView.RowAnimation.automatic
        if !isProcessingChat && userSent == .ai {
            animation = .none
        }
        
        tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: animation)
        rowsToType.append(row + 1)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
        
        if ChatStorageHelper.getAllChats().count % 5 == 0 && !firstChat {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                DispatchQueue.main.async {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
    
    func setBubbleImage(imageView: UIImageView, isUser: Bool) {
        let name: String
        if isUser {
            name = "chat_bubble_sent"
            imageView.tintColor = Colors.userChatBubbleColor
        } else {
            name = "chat_bubble_received"
            imageView.tintColor = Colors.aiChatBubbleColor
        }
        
        guard let image = UIImage(named: name) else { return }
        imageView.image = image
            .resizableImage(withCapInsets:
                                UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                            resizingMode: .stretch)
            .withRenderingMode(.alwaysTemplate)
    }
    
    func updateRemainingText() {
        DispatchQueue.main.async {
            if UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                self.remainingView.isHidden = true
                self.remainingShadowView.isHidden = true
                self.promoView.isHidden = true
                self.promoShadowView.isHidden = true
            } else {
                if self.remaining >= 0 {
                    self.remainingView.isHidden = false
                    self.remainingShadowView.isHidden = false
                    self.promoView.isHidden = false
                    self.promoShadowView.isHidden = false
                    
                    self.chatsRemainingText.text = "You have \(self.remaining) chats remaining today..."
                    
                    //TODO: - If remaining % 5 is 0 then serve an ad
                    if self.remaining % 5 == 0 && !self.firstChat {
                        if self.interstitial != nil {
                            //Display ad
                            self.interstitial?.present(fromRootViewController: self) {
                                let reward = self.interstitial?.adReward
                                if reward?.amount == 0 {
                                    //TODO: - Handle early ad close
                                }
                            }
                        }
                    }
                } else {
                    self.remainingView.isHidden = true
                    self.remainingShadowView.isHidden = true
                    self.promoView.isHidden = true
                    self.promoShadowView.isHidden = true
                }
            }
        }
    }
    
    func loadGAD() {
        failedToLoadInterstitial = false
        
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            let request = GADRequest()
            GADRewardedInterstitialAd.load(withAdUnitID: Private.rewardedInterstitialID, request: request, completionHandler: { [self] ad, error in
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

extension MainViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateInputTextViewSize(textView: textView)
        
        if textView.text == "" || textView.textColor == .lightGray {
            submitButton.isEnabled = false
        } else {
            submitButton.isEnabled = true
        }
    }
    
    func updateInputTextViewSize(textView: UITextView) {
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        guard textView.contentSize.height < 70.0 else { textView.isScrollEnabled = true; return }
        
        textView.isScrollEnabled = false
        textView.constraints.forEach{ (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            view.endEditing(true)
            return false
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = Colors.chatTextColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = inputPlaceholder
            textView.textColor = .lightGray
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        
        if isProcessingChat {
            return ChatStorageHelper.getAllChats().count + 1
        }
        
        return ChatStorageHelper.getAllChats().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "paddingCell")!
        }
        
        // Show loading chat row
        if isProcessingChat {
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! ChatTableViewCell
                setBubbleImage(imageView: cell.bubbleImageView, isUser: false)
                cell.loadingImageView.image = UIImage.gifImageWithName("loadingDots")
                return cell
            }
        }
        
        let currentChat = ChatStorageHelper.getAllChats()[indexPath.row]
        let cell: ChatTableViewCell
        
        if currentChat.userSent == .user {
            cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ChatTableViewCell
            setBubbleImage(imageView: cell.bubbleImageView, isUser: true)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "aiCell", for: indexPath) as! ChatTableViewCell
            setBubbleImage(imageView: cell.bubbleImageView, isUser: false)
        }
        
        let finalText = currentChat.text
        
        //TODO: - Wait, does this trigger submitSoftDisable even when the user text is being typed out?
        //TODO: - Need to remove rows from rowsToType once they are typed (Done?)
        if rowsToType.contains(indexPath.row) {
//            cell.chatText.text = ""
            let chatTextMutableAttriburtedString = NSMutableAttributedString()
            cell.chatText.attributedText = chatTextMutableAttriburtedString
            
            var writingTask: DispatchWorkItem?
            writingTask = DispatchWorkItem { () in
                for character in finalText {
                    DispatchQueue.main.async {
                        let initialHeight = cell.frame.height
                        tableView.beginUpdates()
//                        cell.chatText.text!.append(character)
                        //TODO: - Fix this bad implementation of the secondary font
                        if (cell.chatText.attributedText!.string + "\(character)").contains("...\n\n") {
                            chatTextMutableAttriburtedString.secondaryFont("\(character)")
                        } else {
                            chatTextMutableAttriburtedString.normal("\(character)")
                        }
                        
                        cell.chatText.attributedText = chatTextMutableAttriburtedString
                        
                        tableView.endUpdates()
                        
                        if cell.frame.height != initialHeight {
                            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
                        }
                    }
                    Thread.sleep(forTimeInterval: 5.0/100)
                }
                
                //AI finished typing, soft enable button and remove row from needing to be typed
                DispatchQueue.main.async {
                    self.submitButton.alpha = 1.0
                    self.submitSoftDisable = false
                    self.rowsToType.remove(at: self.rowsToType.firstIndex(of: indexPath.row)!)
                }
            }
            
            if let task = writingTask {
                let queue = DispatchQueue(label: "typespeed", qos: DispatchQoS.userInteractive)
                queue.asyncAfter(deadline: .now() + 0.05, execute: task)
            }
        } else {
            cell.chatText.text = finalText
        }
        
        //        cell.chatText.setTextWithTypeAnimation(typedText: "aldjflahsdljfhajklfhkljahdfkhasdjf hjkasdghfkjldljkfhajlsdfhk sdkfghkja dgfkjgasdjhfg aksdgf g sadfhg ajkhdfkad fkljh alkjdfljkahdfjk alsdkjfkl dafjkhdaljkfhkjahsdf klasdjfl h")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        //Show Chat Messages
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return bottomView.frame.height + 50 // Add extra padding if user is not Ultra
        }
        
        return tableView.rowHeight
    }
}

extension MainViewController: HTTPSHelperDelegate {
    func didRegisterUser(json: [String : Any]) {
        guard let body = json["Body"] as? [String: Any] else {
            print("Error! No Body in response...\n\(json)")
            return
        }
        
        guard let authToken = body["authToken"] as? String else {
            print("Error! No AuthToken in response...\n\(json)")
            return
        }
        
        HTTPSHelper.getRemaining(delegate: self, authToken: authToken)
        UserDefaults.standard.set(authToken, forKey: Constants.authTokenKey)
    }
    
    func getRemaining(json: [String : Any]) {
        guard let body = json["Body"] as? [String: Any] else {
            print("Error! No Body in response...\n\(json)")
            return
        }
        
        guard let remaining = body["remaining"] as? Int else {
            print("Error! No AuthToken in response...\n\(json)")
            return
        }
        
        self.remaining = remaining
        updateRemainingText()
    }
    
    func getChat(json: [String : Any]) {
        if UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            submitButton.isEnabled = true
        }
        
        if isProcessingChat {
            isProcessingChat = false
            tableView.deleteRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)], with: .none)
        }
        
        guard let success = json["Success"] as? Int else {
            print("Error! No success in response...\n\(json)")
            return
        }
        
        if success == 1 {
            //Everything's good!
            guard let body = json["Body"] as? [String: Any] else {
                print("Error! No Body in response...\n\(json)")
                return
            }
            
            guard let output = body["output"] as? String else {
                print("Error! No Output in response...\n\(json)")
                return
            }
            
            guard let remaining = body["remaining"] as? Int else {
                print("Error! No Remaining in response...\n\(json)")
                return
            }
            
            guard let finishReason = body["finishReason"] as? String else {
                print("Error! No Finish Reason in response...\n\(json)")
                return
            }
            
            print(finishReason)
            // Trim first two lines off of output
            var trimmedOutput = output
            if output.contains("\n\n") {
                let firstOccurence = output.range(of: "\n\n")!
                trimmedOutput.removeSubrange(output.startIndex..<firstOccurence.upperBound)
            }
            
            if finishReason == FinishReasons.length && !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                trimmedOutput += "...\n\nThis answer is too long for your plan. Please upgrade to Ultra for unlimited length."
            }
            
            self.remaining = remaining
            firstChat = false
            updateRemainingText()
            addChat(message: trimmedOutput, userSent: .ai)
        } else if success == 51 {
            //Too many chats generated
            guard let body = json["Body"] as? [String: Any] else {
                print("Wait... a body is supposed to be sent here, hm")
                return
            }
            
            guard let output = body["output"] as? String else {
                print("Error! No output in body...\n\(json)")
                return
            }
            
            let ac = UIAlertController(title: "Limit Reached", message: "You've reached your daily chat limit. Upgrade for unlimited chats...", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Close", style: .cancel))
            ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
                self.goToUltraPurchase()
            }))
            present(ac, animated: true)
            
            addChat(message: output, userSent: .ai)
        } else {
            print("Error! Unhandled error number...\n\(json)")
        }
    }
    
    func getChatError() {
        DispatchQueue.main.async {
            if self.isProcessingChat {
                self.isProcessingChat = false
                self.tableView.deleteRows(at: [IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0)], with: .none)
            }
            
            self.addChat(message: "There was an issue getting your chat. Please try a different prompt.", userSent: .ai)
        }
    }
}

//MARK: - In App Purchase Handling
extension MainViewController: IAPHTTPSHelperDelegate {
    func didGetIAPStuffFromServer(json: [String : Any]) {
    }
    
    
    /* Received Products Did Load Notification
     - Called when IAPMAnager returns the subscription product */
    @objc func receivedProductsDidLoadNotification(notification: Notification) {
        guard let product = IAPManager.shared.products?[0] else { return }
        IAPManager.shared.purchaseProduct(product: product, success: {
            /* Successfully Purchased Product */
            
            DispatchQueue.main.async {
                self.doServerPremiumCheck()
            }
        }, failure: {(Error) in })
        
        doServerPremiumCheck()
    }
    
    /* Checks the server if the user is premium, validates Receipt with Apple */
    func doServerPremiumCheck() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print(receiptData)
                
                let receiptString = receiptData.base64EncodedString(options: [])
                print(receiptString)
                
                IAPHTTPSHelper.validateAndSaveReceipt(authToken: UserDefaults.standard.string(forKey: Constants.authTokenKey)!, receiptData: receiptData, delegate: self)
            } catch {
                
            }
        } else {
            /* No receipt, so set isPremium to false */
            setPremiumToFalse()
        }
    }
    
    func setPremiumToFalse() {
        UserDefaults.standard.set(false, forKey: Constants.userDefaultStoredIsPremium)
        
        setPremiumItems()
    }
    
    func setPremiumToTrue() {
        UserDefaults.standard.set(true, forKey: Constants.userDefaultStoredIsPremium)
        
        setPremiumItems()
    }
    
    //MARK: - IAPHTTPSHelper Delegate Function
    /* Did Validate Save Update Receipt
     * IAPHTTPSHelperDelegate Function
     - Called when Receipt is saved or not
     - Returns if user is premium or not
     */
    func didValidateSaveUpdateReceipt(json: [String : Any]) {
        /**
         ValidateAndUpdateReceipt Response JSON
         
         {
         "Success": Int
         "Body?":  {
         "isPremium": Bool
         }
         (Error)         "Type?": Int
         (Error) "       Message?" String
         }
         */
        if let success = json["Success"] as? Int {
            if success == 1 {
                if let body = json["Body"] as? [String: Any] {
                    if let isPremium = body["isPremium"] as? Bool {
                        if isPremium {
                            /* Server has validated user is Premium */
                            UserDefaults.standard.set(true, forKey: Constants.userDefaultStoredIsPremium)
                        } else {
                            /* Server has validated user is Free */
                            UserDefaults.standard.set(false, forKey: Constants.userDefaultStoredIsPremium)
                        }
                        
                        setPremiumItems()
                    }
                }
            }
        }
    }
}

extension MainViewController: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present full screen content")
        
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content")
        
        loadGAD()
    }
}

extension MainViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            adViewHeightConstraint.constant = 50.0
            adShadowView.isHidden = false
            
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(bannerView)
            adView.addConstraints([NSLayoutConstraint(item: bannerView, attribute: .centerY, relatedBy: .equal, toItem: adView, attribute: .centerY, multiplier: 1, constant: 0), NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: adView, attribute: .centerX, multiplier: 1, constant: 0)])
        }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        
        adViewHeightConstraint.constant = 0.0
        adShadowView.isHidden = true
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}
