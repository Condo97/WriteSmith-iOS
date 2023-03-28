//
//  UltraPurchaseViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit
import Foundation
import SafariServices

enum PlanType {
    case none
    case weekly
    case monthly
}

class UltraPurchaseViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var ultraLabel: UILabel!
    @IBOutlet weak var unleashLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var everythingElseView: UIView!
    
    @IBOutlet weak var ultraCheckLabel: UILabel!
    @IBOutlet weak var unlockCheckLabel: UILabel!
    @IBOutlet weak var removeAdsCheckLabel: UILabel!
    @IBOutlet weak var noCommitmentsCheckLabel: UILabel!
    
    @IBOutlet weak var weeklyRoundedView: RoundedView!
    @IBOutlet weak var weeklyText: UILabel!
    @IBOutlet weak var weeklyActivityView: UIActivityIndicatorView!
    
    @IBOutlet weak var monthlyRoundedView: RoundedView!
    @IBOutlet weak var monthlyText: UILabel!
    @IBOutlet weak var monthlyActivityView: UIActivityIndicatorView!
    
    var fromStart: Bool = false
    var restorePressed: Bool = false
    var shouldRestoreFromSettings: Bool = false
    var buttonsAreSoftDisabled: Bool = false
    
    var selectedPlanType: PlanType = .none
    
    //TODO: - Get ProductIDs from Server
    //    let productIDsForTesting: Set<String> = ["com.acapplications.mindseye.in_app_purchase_premium"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let weeklyDisplayPrice = (UserDefaults.standard.string(forKey: Constants.userDefaultStoredWeeklyDisplayPrice) ?? Constants.defaultWeeklyDisplayPrice) as String
        let monthlyDisplayPrice = (UserDefaults.standard.string(forKey: Constants.userDefaultStoredMonthlyDisplayPrice) ?? Constants.defaultMonthlyDisplayPrice) as String
        
        
        // Setup imageView which is the brain
        setupUltraImageView()
        
        // Setup attributed label color
        let ultraCheckText = NSMutableAttributedStringBuilder()
            .bold("ULTRA")
            .normal(" Unlimited Chats")
            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
            .get()
        ultraCheckLabel.attributedText = ultraCheckText
        
        let unlockCheckText = NSMutableAttributedStringBuilder()
            .bold("Unlock")
            .normal(" Essay Writer")
            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
            .get()
        unlockCheckLabel.attributedText = unlockCheckText
        
        let removeAdsCheckText = NSMutableAttributedStringBuilder()
            .bold("Remove")
            .normal(" Ads")
            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
            .get()
        removeAdsCheckLabel.attributedText = removeAdsCheckText
        
        let noCommitmentsCheckText = NSMutableAttributedStringBuilder()
            .bold("No Commitments,")
            .normal(" Cancel Anytime")
            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
            .get()
        noCommitmentsCheckLabel.attributedText = noCommitmentsCheckText
        
        
        // Setup Weekly "Button" Text
        let weeklyString = NSMutableAttributedStringBuilder()
            .boldAndBig("Start Free Trial & Plan\n")
            .secondarySmaller("3 Day Trial - Then \(weeklyDisplayPrice) / week")
            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatBubbleColor)
            .get()
        weeklyText.attributedText = weeklyString
        
        // Setup Weekly Gesture Recognizer
        let weeklyGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedWeekly))
        weeklyGestureRecognizer.cancelsTouchesInView = false
        weeklyRoundedView.addGestureRecognizer(weeklyGestureRecognizer)
        
        // Setup Annual "Button" Text
        let monthlyString = NSMutableAttributedStringBuilder()
            .normalAndBig("Monthly - \(monthlyDisplayPrice) / month\n", size: 22.0)
            .secondarySmaller("That's 30% Off Weekly!")
            .addGlobalAttribute(.foregroundColor, value: Colors.elementBackgroundColor)
            .get()
        monthlyText.attributedText = monthlyString
        
        // Setup Annual Gesture Recognizer
        let monthlyGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedMonthly))
        monthlyGestureRecognizer.cancelsTouchesInView = false
        monthlyRoundedView.addGestureRecognizer(monthlyGestureRecognizer)
        
        // Do setup server calls in case didFinishLaunchingWithOptions isn't called
        if UserDefaults.standard.string(forKey: Constants.authTokenKey) == nil {
            HTTPSHelper.registerUser(delegate: self)
        }
        
        if UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) == nil {
            UserDefaults.standard.set("https://apple.com/", forKey: Constants.userDefaultStoredShareURL)
        }
        
        // Setup close button fade in
        closeButton.alpha = 0.5
        closeButton.setBackgroundImage(UIImage.init(systemName: "xmark"), for: .normal)
        
        HTTPSHelper.getAndSaveImportantConstants(delegate: self)
//        HTTPSHelper.getDisplayPrice(delegate: self)
//        HTTPSHelper.getShareURL(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Do close button fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 4, animations: {
                self.closeButton.alpha = 1.0
                self.closeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
        })
        
        if shouldRestoreFromSettings {
            restorePurchases()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // If changed from light to dark or vice versa, update the ultraImageView with the correct image
        setupUltraImageView()
    }
    
    func setupUltraImageView() {
        if traitCollection.userInterfaceStyle != .dark {
            // Light image
            imageView.image = UIImage(named: Constants.ultraLightImageName)
        } else {
            // Dark image
            imageView.image = UIImage(named: Constants.ultraDarkImageName)
        }
    }
    
    func disableButtons() {
        closeButton.isEnabled = false
        buttonsAreSoftDisabled = true
        weeklyRoundedView.alpha = 0.5
        monthlyRoundedView.alpha = 0.5
    }
    
    func enableButtons() {
        closeButton.isEnabled = true
        buttonsAreSoftDisabled = false
        weeklyRoundedView.alpha = 1.0
        monthlyRoundedView.alpha = 1.0
        weeklyActivityView.stopAnimating()
        monthlyActivityView.stopAnimating()
    }
    
    func getIAPStuffFromServer() {
        if let authToken = UserDefaults.standard.string(forKey: Constants.authTokenKey) {
            IAPHTTPSHelper.getIAPStuffFromServer(authToken: authToken, delegate: self)
        } else {
            let alertController = UIAlertController(title: "Can't Reach Sever", message: "Please make sure your internet connection is enabled and try again later.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel))
            present(alertController, animated: true)
            
            enableButtons()
        }
    }
    
    @objc func tappedWeekly(sender: Any) {
        if !buttonsAreSoftDisabled {
            bounce(sender: weeklyRoundedView)
            
            restorePressed = false
            selectedPlanType = .weekly
            weeklyActivityView.startAnimating()
            disableButtons()
            getIAPStuffFromServer()
        }
    }
    
    @objc func tappedMonthly(sender: Any) {
        if !buttonsAreSoftDisabled {
            bounce(sender: monthlyRoundedView)
            
            restorePressed = false
            selectedPlanType = .monthly
            monthlyActivityView.startAnimating()
            disableButtons()
            getIAPStuffFromServer()
        }
    }
    
    
    @IBAction func startSubscriptionButton(_ sender: Any) {
        restorePressed = false
        disableButtons()
        getIAPStuffFromServer()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        if fromStart {
            UserDefaults.standard.set(true, forKey: Constants.userDefaultHasFinishedIntro)
            performSegue(withIdentifier: "toMainView", sender: nil)
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func privacyPolicyButton(_ sender: Any) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.privacyPolicy)")!
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    @IBAction func termsAndConditionsButton(_ sender: Any) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.termsAndConditions)")!
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    @IBAction func restorePurchaseButton(_ sender: Any) {
        restorePurchases()
    }
    
    func restorePurchases() {
        restorePressed = true
        disableButtons()
        getIAPStuffFromServer()
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "toMainView" {
             if let tabBarController = segue.destination as? GlobalTabBarViewController {
                 if let nav = tabBarController.viewControllers?[tabBarController.firstViewController] as? UINavigationController {
                     if let detailVC = nav.topViewController as? ChatViewController {
                         detailVC.shouldShowUltra = false
                     }
                 }
             }
         }
     }
    
    // Bounce Weekly and Annual RoundedViews
    @objc private func bounce(sender: RoundedView) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { (_) in
            UIView.animate(withDuration: 0.4, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                sender.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
}

//MARK: - In App Purchase Handling
extension UltraPurchaseViewController: IAPHTTPSHelperDelegate {
    func didGetIAPStuffFromServer(json: [String : Any]) {
        guard let success = json["Success"] as? Int else { showGeneralIAPErrorAndUnhide(); return }
        
        if success == 1 {
            guard let body = json["Body"] as? [String: Any] else { showGeneralIAPErrorAndUnhide(); return }
            guard let sharedSecret = body["sharedSecret"] as? String else { showGeneralIAPErrorAndUnhide(); return }
            guard let productIDs = body["productIDs"] as? [String] else { showGeneralIAPErrorAndUnhide(); return }
            
            if productIDs.count > 0 {
                let productIDsSet = Set<String>(productIDs)
                
                IAPManager.shared.startWith(arrayOfIds: productIDsSet, sharedSecret: sharedSecret)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.receivedProductsDidLoadNotification(notification:)), name: IAP_PRODUCTS_DID_LOAD_NOTIFICATION, object: nil)
            }
        }
    }
    
    func showGeneralIAPErrorAndUnhide() {
        let alert = UIAlertController(title: "Error Subscribing", message: "Please try subscribing again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { Action in
            self.enableButtons()
        }))
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { Action in
            self.startSubscriptionButton(self)
        }))
        present(alert, animated: true)
    }
    
    
    /* Received Products Did Load Notification
     - Called when IAPMAnager returns the subscription product */
    @objc func receivedProductsDidLoadNotification(notification: Notification) {
        guard let products = IAPManager.shared.products else { return }
        var productsToIndex: [PlanType: Int] = [:]
        for i in 0..<products.count {
            let product = products[i]
            if product.productIdentifier == Constants.weeklyProductIdentifier {
                productsToIndex[.weekly] = i
            } else if product.productIdentifier == Constants.monthlyProductIdentifier {
                productsToIndex[.monthly] = i
            }
        }
        
        if products.count > 0 {
            if restorePressed {
                IAPManager.shared.restorePurchases(success: {
                    /* Successfully Restored Purchase */
                    DispatchQueue.main.async {
                        self.doServerPremiumCheck()
                    }
                }, failure: {(Error) in
                    /* Restore Product Unsuccessful */
                    //TODO: - Handle IAP Purchase Product Error
                    let alertController = UIAlertController(title: "Error Subscribing", message: "Please try your subscription again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { alertAction in
                        self.startSubscriptionButton(self)
                    }))
                    alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { alertAction in
                        self.enableButtons()
                    }))
                    self.present(alertController, animated: true)
                })
            } else if selectedPlanType == .weekly {
                guard let weeklyIndex = productsToIndex[.weekly] else {
                    enableButtons()
                    return
                }
                
                IAPManager.shared.purchaseProduct(product: products[weeklyIndex], success: { (transaction) in
                    /* Successfully Purchased Product */
                    DispatchQueue.main.async {
                        // Log manual event to Tenjin
                        TenjinSDK.sendEvent(withName: "subWeekly")
                        
                        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
                            do {
                                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                                TenjinSDK.transaction(transaction, andReceipt: receiptData)
                                TenjinSDK.updatePostbackConversionValue(Int32(UserDefaults.standard.string(forKey: Constants.userDefaultStoredWeeklyDisplayPrice) ?? Constants.defaultWeeklyDisplayPrice) ?? 3)
                            } catch {
                                print("Couldn't report weekly subscription to Tenjin!")
                            }
                        }
                        
                        self.doServerPremiumCheck()
                    }
                }, failure: {(Error) in
                    /* Purchase Product Unsuccessful */
                    //TODO: - Handle IAP Purchase Product Error
                    let alertController = UIAlertController(title: "Error Subscribing", message: "Please try your subscription again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { alertAction in
                        self.startSubscriptionButton(self)
                    }))
                    alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { alertAction in
                        self.enableButtons()
                    }))
                    self.present(alertController, animated: true)
                })
            } else if selectedPlanType == .monthly {
                guard let monthlyIndex = productsToIndex[.monthly] else {
                    enableButtons()
                    return
                }
                
                IAPManager.shared.purchaseProduct(product: products[monthlyIndex], success: { transaction in
                    /* Successfully Purchased Product */
                    DispatchQueue.main.async {
                        // Log manual event to Tenjin
                        TenjinSDK.sendEvent(withName: "subMonthly")
                        
                        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
                            do {
                                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                                TenjinSDK.transaction(transaction, andReceipt: receiptData)
                                TenjinSDK.updatePostbackConversionValue(Int32(UserDefaults.standard.string(forKey: Constants.userDefaultStoredMonthlyDisplayPrice) ?? Constants.defaultWeeklyDisplayPrice) ?? 10)
                            } catch {
                                print("Couldn't report monthly subscription to Tenjin!")
                            }
                        }
                        
                        self.doServerPremiumCheck()
                    }
                }, failure: {(Error) in
                    /* Purchase Product Unsuccessful */
                    //TODO: - Handle IAP Purchase Product Error
                    let alertController = UIAlertController(title: "Error Subscribing", message: "Please try your subscription again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { alertAction in
                        self.startSubscriptionButton(self)
                    }))
                    alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { alertAction in
                        self.enableButtons()
                    }))
                    self.present(alertController, animated: true)
                })
            }
            
            doServerPremiumCheck()
        } else {
            let alertController = UIAlertController(title: "Can't Reach Sever", message: "Please make sure your internet connection is enabled and try again later.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel))
            present(alertController, animated: true)
            
            enableButtons()
        }
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
                showGeneralIAPErrorAndUnhide()
            }
        } else {
            /* No receipt, so set isPremium to false */
            setPremiumToFalse()
        }
    }
    
    func setPremiumToFalse() {
        UserDefaults.standard.set(false, forKey: Constants.userDefaultStoredIsPremium)
    }
    
    func setPremiumToTrue() {
        UserDefaults.standard.set(true, forKey: Constants.userDefaultStoredIsPremium)
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
        
        guard let success = json["Success"] as? Int else { showGeneralIAPErrorAndUnhide(); return }
        
        if success == 1 {
            guard let body = json["Body"] as? [String: Any] else { showGeneralIAPErrorAndUnhide(); return }
            guard let isPremium = body["isPremium"] as? Bool else { showGeneralIAPErrorAndUnhide(); return }
             
            if isPremium {
                /* Server has validated user is Premium */
                setPremiumToTrue()
                
                if self.fromStart {
                    UserDefaults.standard.set(true, forKey: Constants.userDefaultHasFinishedIntro)
                    self.performSegue(withIdentifier: "toMainView", sender: nil)
                } else {
                    self.dismiss(animated: true)
                }
            } else {
                /* Server has validated user is Free */
                setPremiumToFalse()
                
                //TODO: - Kind've hack-y but works here, fix this implementation
                if restorePressed {
                    let alertController = UIAlertController(title: "Error Restoring", message: "Couldn't find your subscription. Please try resubscribing.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { alertAction in
                        self.startSubscriptionButton(self)
                    }))
                    alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { alertAction in
                        self.enableButtons()
                    }))
                    self.present(alertController, animated: true)
                    
                    restorePressed = false
                }
            }
        }
    }
}

extension UltraPurchaseViewController: HTTPSHelperDelegate {
    func didRegisterUser(json: [String : Any]?) {
        if let body = json?["Body"] as? [String: Any] {
            if let authToken = body["authToken"] as? String {
                UserDefaults.standard.set(authToken, forKey: Constants.authTokenKey)
            }
        }
    }
    
//    func didGetDisplayPrice(json: [String : Any]) {
//        if let body = json["Body"] as? [String: Any] {
//            if let weeklyDisplayPrice = body[Constants.bodyWeeklyDisplayPriceName] as? String {
//                if let monthlyDisplayPrice = body[Constants.bodyMonthlyDisplayPriceName] as? String {
//                    UserDefaults.standard.set(weeklyDisplayPrice, forKey: Constants.userDefaultStoredWeeklyDisplayPrice)
//                    UserDefaults.standard.set(monthlyDisplayPrice, forKey: Constants.userDefaultStoredMonthlyDisplayPrice)
//                } else {
//                    UserDefaults.standard.set(Constants.defaultWeeklyDisplayPrice, forKey: Constants.userDefaultStoredWeeklyDisplayPrice)
//                    UserDefaults.standard.set(Constants.defaultMonthlyDisplayPrice, forKey: Constants.userDefaultStoredMonthlyDisplayPrice)
//                }
//            } else {
//                UserDefaults.standard.set(Constants.defaultWeeklyDisplayPrice, forKey: Constants.userDefaultStoredWeeklyDisplayPrice)
//                UserDefaults.standard.set(Constants.defaultMonthlyDisplayPrice, forKey: Constants.userDefaultStoredMonthlyDisplayPrice)
//            }
//        } else {
//            UserDefaults.standard.set(Constants.defaultWeeklyDisplayPrice, forKey: Constants.userDefaultStoredWeeklyDisplayPrice)
//            UserDefaults.standard.set(Constants.defaultMonthlyDisplayPrice, forKey: Constants.userDefaultStoredMonthlyDisplayPrice)
//        }
//    }
    
    func getRemaining(json: [String : Any]?) {
        
    }
    
    func didGetAndSaveImportantConstants(json: [String : Any]?) {
        
    }
    
    func getChat(json: [String : Any]?) {
        
    }
    
    func getChatError() {
        
    }
    
//    func didGetShareURL(json: [String : Any]) {
//        if let body = json["Body"] as? [String: Any] {
//            if let shareURL = body["shareURL"] as? String {
//                UserDefaults.standard.set(shareURL, forKey: Constants.userDefaultStoredShareURL)
//            }
//        }
//    }
}

