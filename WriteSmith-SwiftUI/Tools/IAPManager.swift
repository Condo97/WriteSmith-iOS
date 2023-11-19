//
//  IAPManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/16/23.
//

import Foundation
import StoreKit
import UIKit

class IAPManager: Any {
    
    static var storeKitTaskHandle: Task<Void, Error>?
    
    enum PurchaseError: Error {
        case pending
        case failed
        case cancelled
    }
    
    static func fetchProducts(productIDs: [String]) async throws -> [Product] {
        let storeProducts = try await Product.products(for: Set(productIDs))
        
        return storeProducts
}
    
//    static func getSubscriptionPeriod(product: Product) -> SubscriptionPeriod? {
//        if let subscription = product.subscription {
//            
//            let unit = subscription.subscriptionPeriod.unit
//            let value = subscription.subscriptionPeriod.value
//            
//            switch unit {
//            case .day:
//                switch value {
//                case 1:
//                    return .daily
//                case 7:
//                    return .weekly
//                default:
//                    return .invalid
//                }
//            case .week:
//                return .weekly
//            case .month:
//                switch value {
//                case 1:
//                    return .monthly
//                case 2:
//                    return .biMonthly
//                case 3:
//                    return .triMonthly
//                case 6:
//                    return .semiYearly
//                default:
//                    return .invalid
//                }
//            case .year:
//                return .yearly
//            @unknown default:
//                return .invalid
//            }
//        }
//        
//        return nil
//    }
    
    static func purchase(_ product: Product) async throws -> Transaction {
        let result = try await product.purchase()
        
        switch result {
        case .pending:
            throw PurchaseError.pending
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                
                return transaction
            case .unverified:
                throw PurchaseError.failed
            }
        case .userCancelled:
            throw PurchaseError.cancelled
        @unknown default:
            assertionFailure("Unexpected result purchasing product in IAPManager")
            throw PurchaseError.failed
        }
        
    }
    
//    static func refreshReceipt() async {
//        class ReceiptRefreshRequestWrapper: NSObject, SKRequestDelegate {
//            
//            private var completion: ((Bool)->Void)?
//            
//            func doReceiptRefresh(completion: @escaping (Bool)->Void) {
//                self.completion = completion
//                
//                let request = SKReceiptRefreshRequest()
//                request.delegate = self
//                request.start()
//            }
//            
//            func requestDidFinish(_ request: SKRequest) {
//                completion?(true)
//            }
//            
//            func request(_ request: SKRequest, didFailWithError error: Error) {
//                print("Error refreshing receipt: \(error.localizedDescription)")
//                completion?(false)
//            }
//        }
//        
//        await withCheckedContinuation { continuation in
//            ReceiptRefreshRequestWrapper().doReceiptRefresh(completion: { success in
//                print("First")
//                continuation.resume()
//            })
//        }
//        
////        ReceiptRefreshRequestWrapper().doReceiptRefresh()
//        
//        print("Second")
//    }
    
    static func startStoreKitListener() {
        storeKitTaskHandle = listenForStoreKitUpdates()
    }
    
    static func listenForStoreKitUpdates() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let Transaction):
                    await Transaction.finish()
                    
                    print("Transaction verified in IAPManager listenForStoreKitUpdates")
                    
                    //TODO: Update isPremium, or do a server check with the new receipt
                    return
                case .unverified:
                    print("Transaction unverified in IAPManager listenForStoreKitUpdates")
                }
            }
        }
    }
    
    static func getVerifiedTransactions() async -> [Transaction] {
        var transactionList: [Transaction] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                switch result {
                case .verified(let Transaction):
                    await Transaction.finish()
                    
                    print("Transaction verified in IAPManager getVerifiedTransactions")
                    
                    transactionList.append(Transaction)
                case .unverified:
                    print("Tranaction unverified in IAPManager getVerifiedTransactions")
                }
            }
        }
        
        return transactionList
    }
    
}
