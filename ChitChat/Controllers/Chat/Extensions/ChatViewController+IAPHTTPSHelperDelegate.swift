//
//  ChatViewController+IAP.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/19/23.
//

import Foundation

//MARK: - In App Purchase Handling
extension ChatViewController: IAPHTTPSHelperDelegate {
    /* Received Products Did Load Notification
     - Called when IAPMAnager returns the subscription product */
    @objc func receivedProductsDidLoadNotification(notification: Notification) {
        guard let product = IAPManager.shared.products?[0] else { return }
        IAPManager.shared.purchaseProduct(product: product, success: { transaction in
            /* Successfully Purchased Product */
            
            DispatchQueue.main.async {
                if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
                    do {
                        let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                        TenjinSDK.transaction(transaction, andReceipt: receiptData)
                    } catch {
                        print("Couldn't report weekly subscription to Tenjin!")
                    }
                }
                
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
                
                guard let authToken = UserDefaults.standard.string(forKey: Constants.authTokenKey) else {
                    print("Didn't have authToken...")
                    setPremiumToFalse()
                    return
                }
                
                IAPHTTPSHelper.validateAndSaveReceipt(authToken: authToken, receiptData: receiptData, delegate: self)
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
    
    func didGetIAPStuffFromServer(json: [String : Any]) {
    }
}
