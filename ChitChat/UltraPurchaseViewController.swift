//
//  UltraPurchaseViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit
import Foundation
import SafariServices

class UltraPurchaseViewController: UIViewController {
    @IBOutlet weak var startSubscriptionButton: RoundedButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var ultraLabel: UILabel!
    @IBOutlet weak var unleashLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var everythingElseView: UIView!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    var fromStart: Bool = false
    var restorePressed: Bool = false
    var shouldRestoreFromSettings: Bool = false
    
    //TODO: - Get ProductIDs from Server
    //    let productIDsForTesting: Set<String> = ["com.acapplications.mindseye.in_app_purchase_premium"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imageView.image = UIImage(named: UserDefaults.standard.string(forKey: GlobalConstants.userDefaultStoredProImageName) ?? StartScreenConstants.rainbowHills)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldRestoreFromSettings {
            restorePurchases()
        }
    }
    
    func disableButtons() {
        closeButton.isEnabled = false
        startSubscriptionButton.isEnabled = false
        activityIndicator.startAnimating()
    }
    
    func enableButtons() {
        closeButton.isEnabled = true
        startSubscriptionButton.isEnabled = true
        activityIndicator.stopAnimating()
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
             if let nav = segue.destination as? UINavigationController {
                 if let detailVC = nav.topViewController as? MainViewController {
                     detailVC.firstLoad = false
                 }
             }
         }
     }
}

//MARK: - In App Purchase Handling
extension UltraPurchaseViewController: IAPHTTPSHelperDelegate {
    func didGetIAPStuffFromServer(json: [String : Any]) {
        guard let success = json["Success"] as? Int else { showGeneralIAPErrorAndUnhide(); return }
        
        if success == 1 {
            //TODO: - Allow for Multiple Product IDs
            //Since there is only one product ID for now, just test for it, get it, and proceed with IAP
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
            } else {
                IAPManager.shared.purchaseProduct(product: products[0], success: {
                    /* Successfully Purchased Product */
                    DispatchQueue.main.async {
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
                UserDefaults.standard.set(true, forKey: Constants.userDefaultStoredIsPremium)
                
                if self.fromStart {
                    UserDefaults.standard.set(true, forKey: Constants.userDefaultHasFinishedIntro)
                    self.performSegue(withIdentifier: "toMainView", sender: nil)
                } else {
                    self.dismiss(animated: true)
                }
            } else {
                /* Server has validated user is Free */
                UserDefaults.standard.set(false, forKey: Constants.userDefaultStoredIsPremium)
                
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

