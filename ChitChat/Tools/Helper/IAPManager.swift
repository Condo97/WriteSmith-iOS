//
//  IAPManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/16/23.
//

import Foundation
import StoreKit

class IAPManager: NSObject {
    
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
    
    static func getSubscriptionPeriod(product: Product) -> SubscriptionPeriod? {
        if let subscription = product.subscription {
            
            let unit = subscription.subscriptionPeriod.unit
            let value = subscription.subscriptionPeriod.value
            
            switch unit {
            case .day:
                switch value {
                case 1:
                    return .daily
                case 7:
                    return .weekly
                default:
                    return .invalid
                }
            case .week:
                return .weekly
            case .month:
                switch value {
                case 1:
                    return .monthly
                case 2:
                    return .biMonthly
                case 3:
                    return .triMonthly
                case 6:
                    return .semiYearly
                default:
                    return .invalid
                }
            case .year:
                return .yearly
            @unknown default:
                return .invalid
            }
        }
        
        return nil
    }
    
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
    
    static func startStoreKitListener() {
        storeKitTaskHandle = listenForStoreKitUpdates()
    }
    
    static func listenForStoreKitUpdates() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let Transaction):
                    print("Transaction verified in IAPManager")
                    
                    await Transaction.finish()
                    
                    //TODO: Update isPremium, or do a server check with the new receipt
                    return
                case .unverified:
                    print("Transaction unverified in IAPManager")
                }
            }
        }
    }
    
}
