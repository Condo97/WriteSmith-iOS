//
//  UltraPurchaseViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit
import Foundation
import SafariServices
import StoreKit

enum PlanType {
    case none
    case weekly
    case monthly
}

protocol UltraViewControllerDelegate {
    func didPurchase()
}

class UltraViewController: UpdatingViewController {
    
    private var productLoadingState = LoadingState<[Product]>.idle {
        didSet {
            print("Product Loading State thing")
        }
    }
    
    var delegate: UltraViewControllerDelegate?
    
    var selectedSubscriptionPeriod: SubscriptionPeriod?
    
    var fromStart: Bool = false
    var restorePressed: Bool = false
    var shouldRestoreFromSettings: Bool = false
    var buttonsAreSoftDisabled: Bool = false
    
    lazy var rootView: UltraView = {
        RegistryHelper.instantiateAsView(nibName: Registry.Ultra.View.ultra, owner: self) as? UltraView
    }()!
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let weeklyDisplayPrice = (UserDefaults.standard.string(forKey: Constants.userDefaultStoredWeeklyDisplayPrice) ?? Constants.defaultWeeklyDisplayPrice) as String
        let monthlyDisplayPrice = (UserDefaults.standard.string(forKey: Constants.userDefaultStoredMonthlyDisplayPrice) ?? Constants.defaultMonthlyDisplayPrice) as String
        
        /* Setup RootView Delegate */
        rootView.delegate = self
        
        // Setup imageView which is the brain
        setupUltraImageView()
        
//        // Setup attributed label color
//        let ultraCheckText = NSMutableAttributedStringBuilder()
//            .bold("ULTRA GPT-4", size: 21.0)
//            .normal(" Intelligence", size: 21.0)
//            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
//            .get()
//        rootView.ultraCheckLabel.attributedText = ultraCheckText
//
//        let unlockCheckText = NSMutableAttributedStringBuilder()
//            .bold("Unlock Unlimited", size: 21.0)
//            .normal(" Chats", size: 21.0)
//            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
//            .get()
//        rootView.unlockCheckLabel.attributedText = unlockCheckText
//
//        let removeAdsCheckText = NSMutableAttributedStringBuilder()
//            .bold("Remove", size: 21.0)
//            .normal(" Ads", size: 21.0)
//            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
//            .get()
//        rootView.removeAdsCheckLabel.attributedText = removeAdsCheckText
//
//        let noCommitmentsCheckText = NSMutableAttributedStringBuilder()
//            .bold("No Commitments,\n", size: 21.0)
//            .normal("Cancel Anytime", size: 21.0)
//            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
//            .get()
//        rootView.noCommitmentsCheckLabel.attributedText = noCommitmentsCheckText
        
        
        // Setup Weekly "Button" Text
        let topWeeklyString = "3 Day Trial - Then \(weeklyDisplayPrice) / week"
        let bottomWeeklyString = "Start Free Trial & Plan"
//        let weeklyString = NSMutableAttributedStringBuilder()
//            .boldAndBig("Start Free Trial & Plan\n")
//            .secondarySmaller("3 Day Trial - Then \(weeklyDisplayPrice) / week")
//            .addGlobalAttribute(.foregroundColor, value: Colors.userChatTextColor)
//            .get()
//        rootView.weeklyText.attributedText = weeklyString
        rootView.weeklyTopText.text = topWeeklyString
        rootView.weeklyBottomText.text = bottomWeeklyString
        
        // Setup Weekly Gesture Recognizer
        let weeklyGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedWeekly))
        weeklyGestureRecognizer.cancelsTouchesInView = false
        rootView.weeklyRoundedView.addGestureRecognizer(weeklyGestureRecognizer)
        
        // Setup Annual "Button" Text
        let monthlyString = NSMutableAttributedStringBuilder()
            .normalAndBig("Monthly - \(monthlyDisplayPrice) / month\n", size: 22.0)
            .secondarySmaller("That's 30% Off Weekly!")
            .addGlobalAttribute(.foregroundColor, value: Colors.userChatBubbleColor)
            .get()
        rootView.monthlyText.attributedText = monthlyString
        
        // Setup Annual Gesture Recognizer
        let monthlyGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedMonthly))
        monthlyGestureRecognizer.cancelsTouchesInView = false
        rootView.monthlyRoundedView.addGestureRecognizer(monthlyGestureRecognizer)
        
        if UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) == nil {
            UserDefaults.standard.set("https://apple.com/", forKey: Constants.userDefaultStoredShareURL)
        }
        
        // Setup close button fade in
        rootView.closeButton.alpha = 0.5
        rootView.closeButton.setBackgroundImage(UIImage.init(systemName: "xmark"), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        productLoadingState = .loading
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Do close button fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 4, animations: {
                self.rootView.closeButton.alpha = 1.0
                self.rootView.closeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
        })
        
        if shouldRestoreFromSettings {
            restorePurchases()
        }
        
        // Start StoreKit Listener
        IAPManager.startStoreKitListener()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // If changed from light to dark or vice versa, update the ultraImageView with the correct image
        setupUltraImageView()
    }
    
    func setupUltraImageView() {
        if traitCollection.userInterfaceStyle != .dark {
            // Light image
            rootView.imageView.image = UIImage(named: Constants.ImageName.ultraLight)
        } else {
            // Dark image
            rootView.imageView.image = UIImage(named: Constants.ImageName.ultraDark)
        }
    }
    
    func closeUltraView() {
        // If from start, instantiate GlobalTabBarController as mainVC from storyboard, otherwise just dismiss
        if fromStart {
            let mainVC = UIStoryboard.init(name: Constants.mainStoryboardName, bundle: Bundle.main).instantiateViewController(withIdentifier: Constants.mainVCStoryboardName) as! GlobalTabBarController
            mainVC.modalPresentationStyle = .fullScreen
            mainVC.fromStart = true
            present(mainVC, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    func disableButtons() {
        DispatchQueue.main.async {
            self.rootView.closeButton.isEnabled = false
            self.buttonsAreSoftDisabled = true
            self.rootView.weeklyRoundedView.alpha = 0.5
            self.rootView.monthlyRoundedView.alpha = 0.5
        }
    }
    
    func enableButtons() {
        DispatchQueue.main.async {
            self.rootView.closeButton.isEnabled = true
            self.buttonsAreSoftDisabled = false
            self.rootView.weeklyRoundedView.alpha = 1.0
            self.rootView.monthlyRoundedView.alpha = 1.0
            self.rootView.weeklyActivityView.stopAnimating()
            self.rootView.monthlyActivityView.stopAnimating()
        }
    }
    
    func getIAPStuffFromServer() {
        if let authToken = UserDefaults.standard.string(forKey: Constants.userDefaultStoredAuthTokenKey) {
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
            bounce(sender: rootView.weeklyRoundedView)
            
            restorePressed = false
            selectedSubscriptionPeriod = .weekly
            rootView.weeklyActivityView.startAnimating()
            disableButtons()
            getIAPStuffFromServer()
        }
    }
    
    @objc func tappedMonthly(sender: Any) {
        if !buttonsAreSoftDisabled {
            bounce(sender: rootView.monthlyRoundedView)
            
            restorePressed = false
            selectedSubscriptionPeriod = .monthly
            rootView.monthlyActivityView.startAnimating()
            disableButtons()
            getIAPStuffFromServer()
        }
    }
    
    
    @IBAction func startSubscriptionButton(_ sender: Any) {
        restorePressed = false
        disableButtons()
        getIAPStuffFromServer()
    }
    
    func restorePurchases() {
        restorePressed = true
        disableButtons()
        getIAPStuffFromServer()
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
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "toMainView" {
             if let tabBarController = segue.destination as? GlobalTabBarController {
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

extension UltraViewController: IAPHTTPSHelperDelegate {
    
    func didGetIAPStuffFromServer(json: [String : Any]) throws {
        guard let success = json["Success"] as? Int else { showGeneralIAPErrorAndUnhide(); return }

        if success == 1 {
            guard let body = json["Body"] as? [String: Any] else { showGeneralIAPErrorAndUnhide(); return }
            guard let sharedSecret = body["sharedSecret"] as? String else { showGeneralIAPErrorAndUnhide(); return }
            guard let productIDs = body["productIDs"] as? [String] else { showGeneralIAPErrorAndUnhide(); return }

            if productIDs.count > 0 {
                
                Task.init {
                    do {
                        // Get products from server
                        let products = try await IAPManager.fetchProducts(productIDs: productIDs)
                        
                        // Set product loading state to loaded
                        productLoadingState = .loaded(products)
                        
                        // Get productToPurchase from products
                        var productToPurchase: Product?
                        products.forEach({ product in
                            if IAPManager.getSubscriptionPeriod(product: product) == selectedSubscriptionPeriod {
                                productToPurchase = product
                            }
                        })
                        
                        guard productToPurchase != nil else {
                            showIAPErrorAndEnableButtonsOrRetry(alertBody: "Could not load subscription from server. Please try again.")
                            return
                        }
                        
                        // Purchase the product!
                        let transaction = try await IAPManager.purchase(productToPurchase!)
                        
                        if let receiptURL = Bundle.main.appStoreReceiptURL, let receiptData = try? Data(contentsOf: receiptURL) {
                            // Validate and update recept with full update TODO: Should this be forced downcast, or is there a better way to do something like this? Maybe subclassing Broadcaster?
                            (PremiumUpdater.sharedBroadcaster.updater as! PremiumUpdater).validateAndUpdateReceiptWithFullUpdate(receiptString: receiptData.base64EncodedString(), completion: {
                                DispatchQueue.main.async {
                                    self.enableButtons()
                                    self.closeUltraView()
                                }
                            })
                        }
                        
                    } catch {
                        productLoadingState = .failed(error)
                        
                        enableButtons()
                    }
                }

                //IAPManager.shared.startWith(arrayOfIds: productIDsSet, sharedSecret: sharedSecret)

                //NotificationCenter.default.addObserver(self, selector: #selector(self.receivedProductsDidLoadNotification(notification:)), name: IAP_PRODUCTS_DID_LOAD_NOTIFICATION, object: nil)
            }
        }
    }
    
    
    private func showIAPErrorAndEnableButtonsOrRetry(alertBody: String) {
        let alert = UIAlertController(title: "Error Subscribing", message: alertBody, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { Action in
            self.enableButtons()
        }))
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { Action in
            self.startSubscriptionButton(self)
        }))
        present(alert, animated: true)
    }
    
}



//extension UltraViewController: IAPHTTPSHelperDelegate {
//    func didGetIAPStuffFromServer(json: [String : Any]) {
//        guard let success = json["Success"] as? Int else { showGeneralIAPErrorAndUnhide(); return }
//
//        if success == 1 {
//            guard let body = json["Body"] as? [String: Any] else { showGeneralIAPErrorAndUnhide(); return }
//            guard let sharedSecret = body["sharedSecret"] as? String else { showGeneralIAPErrorAndUnhide(); return }
//            guard let productIDs = body["productIDs"] as? [String] else { showGeneralIAPErrorAndUnhide(); return }
//
//            if productIDs.count > 0 {
//                let productIDsSet = Set<String>(productIDs)
//
//                IAPManager.shared.startWith(arrayOfIds: productIDsSet, sharedSecret: sharedSecret)
//
//                NotificationCenter.default.addObserver(self, selector: #selector(self.receivedProductsDidLoadNotification(notification:)), name: IAP_PRODUCTS_DID_LOAD_NOTIFICATION, object: nil)
//            }
//        }
//    }
//
//    func showGeneralIAPErrorAndUnhide() {
//        let alert = UIAlertController(title: "Error Subscribing", message: "Please try subscribing again.", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { Action in
//            self.enableButtons()
//        }))
//        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { Action in
//            self.startSubscriptionButton(self)
//        }))
//        present(alert, animated: true)
//    }
//
//
//    /* Received Products Did Load Notification
//     - Called when IAPMAnager returns the subscription product */
//    @objc func receivedProductsDidLoadNotification(notification: Notification) {
//        guard let products = IAPManager.shared.products else { return }
//        var productsToIndex: [PlanType: Int] = [:]
//        for i in 0..<products.count {
//            let product = products[i]
//            if product.productIdentifier == Constants.weeklyProductIdentifier {
//                productsToIndex[.weekly] = i
//            } else if product.productIdentifier == Constants.monthlyProductIdentifier {
//                productsToIndex[.monthly] = i
//            }
//        }
//
//        if products.count > 0 {
//            if restorePressed {
//                IAPManager.shared.restorePurchases(success: {
//                    /* Successfully Restored Purchase */
//                    DispatchQueue.main.async {
//                        self.doServerPremiumCheck()
//                    }
//                }, failure: {(Error) in
//                    /* Restore Product Unsuccessful */
//                    //TODO: - Handle IAP Purchase Product Error
//                    let alertController = UIAlertController(title: "Error Subscribing", message: "Please try your subscription again.", preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { alertAction in
//                        self.startSubscriptionButton(self)
//                    }))
//                    alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { alertAction in
//                        self.enableButtons()
//                    }))
//                    self.present(alertController, animated: true)
//                })
//            } else if selectedPlanType == .weekly {
//                guard let weeklyIndex = productsToIndex[.weekly] else {
//                    enableButtons()
//                    return
//                }
//
//                IAPManager.shared.purchaseProduct(product: products[weeklyIndex], success: { (transaction) in
//                    /* Successfully Purchased Product */
//                    DispatchQueue.main.async {
//                        // Log manual event to Tenjin
//                        TenjinSDK.sendEvent(withName: "subWeekly")
//
//                        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
//                            do {
//                                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
//                                TenjinSDK.transaction(transaction, andReceipt: receiptData)
//                                TenjinSDK.updatePostbackConversionValue(Int32(UserDefaults.standard.string(forKey: Constants.userDefaultStoredWeeklyDisplayPrice) ?? Constants.defaultWeeklyDisplayPrice) ?? 3)
//                            } catch {
//                                print("Couldn't report weekly subscription to Tenjin!")
//                            }
//                        }
//
//                        self.doServerPremiumCheck()
//                    }
//                }, failure: {(Error) in
//                    /* Purchase Product Unsuccessful */
//                    //TODO: - Handle IAP Purchase Product Error
//                    let alertController = UIAlertController(title: "Error Subscribing", message: "Please try your subscription again.", preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { alertAction in
//                        self.startSubscriptionButton(self)
//                    }))
//                    alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { alertAction in
//                        self.enableButtons()
//                    }))
//                    self.present(alertController, animated: true)
//                })
//            } else if selectedPlanType == .monthly {
//                guard let monthlyIndex = productsToIndex[.monthly] else {
//                    enableButtons()
//                    return
//                }
//
//                IAPManager.shared.purchaseProduct(product: products[monthlyIndex], success: { transaction in
//                    /* Successfully Purchased Product */
//                    DispatchQueue.main.async {
//                        // Log manual event to Tenjin
//                        TenjinSDK.sendEvent(withName: "subMonthly")
//
//                        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
//                            do {
//                                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
//                                TenjinSDK.transaction(transaction, andReceipt: receiptData)
//                                TenjinSDK.updatePostbackConversionValue(Int32(UserDefaults.standard.string(forKey: Constants.userDefaultStoredMonthlyDisplayPrice) ?? Constants.defaultWeeklyDisplayPrice) ?? 10)
//                            } catch {
//                                print("Couldn't report monthly subscription to Tenjin!")
//                            }
//                        }
//
//                        self.doServerPremiumCheck()
//                    }
//                }, failure: {(Error) in
//                    /* Purchase Product Unsuccessful */
//                    //TODO: - Handle IAP Purchase Product Error
//                    let alertController = UIAlertController(title: "Error Subscribing", message: "Please try your subscription again.", preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { alertAction in
//                        self.startSubscriptionButton(self)
//                    }))
//                    alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { alertAction in
//                        self.enableButtons()
//                    }))
//                    self.present(alertController, animated: true)
//                })
//            }
//
//            doServerPremiumCheck()
//        } else {
//            let alertController = UIAlertController(title: "Can't Reach Sever", message: "Please make sure your internet connection is enabled and try again later.", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "Close", style: .cancel))
//            present(alertController, animated: true)
//
//            enableButtons()
//        }
//    }
//
//    /* Checks the server if the user is premium, validates Receipt with Apple */
//    func doServerPremiumCheck() {
//        PremiumUpdater.sharedBroadcaster.fullUpdate(completion: {
//            if PremiumHelper.get() {
//                /* Server has validated user is Premium */
//                self.updatePremium()
//
//                self.dismiss(animated: true)
//
//            } else {
//                /* Server has validated user is Free */
//                self.updatePremium()
//
//                //TODO: - Kind've hack-y but works here, fix this implementation
//                if self.restorePressed {
//                    let alertController = UIAlertController(title: "Error Restoring", message: "Couldn't find your subscription. Please try resubscribing.", preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { alertAction in
//                        self.startSubscriptionButton(self)
//                    }))
//                    alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { alertAction in
//                        self.enableButtons()
//                    }))
//                    self.present(alertController, animated: true)
//
//                    self.restorePressed = false
//                }
//            }
//        })
//    }
//
//    func updatePremium() {
//        PremiumUpdater.sharedBroadcaster.fullUpdate()
//    }
//
//}
