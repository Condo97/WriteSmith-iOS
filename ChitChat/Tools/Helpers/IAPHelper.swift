//
//  IAPHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/2/23.
//

import Foundation

class IAPHelper: Any {
    
    /* Gets local receiptString or nil if unsuccessful */
    static func getLocalReceiptString() -> String? {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        guard FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            return nil
        }
        
        do {
            let receiptData = try Data(contentsOf: appStoreReceiptURL)
            return receiptData.base64EncodedString()
        } catch {
            return nil
        }
    }
    
}
