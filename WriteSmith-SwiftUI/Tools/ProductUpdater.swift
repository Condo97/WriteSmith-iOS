//
//  ProductUpdater.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/7/23.
//

import Foundation
import StoreKit
import SwiftUI
import TenjinSDK

class ProductUpdater: ObservableObject {
    
    @Published var shouldRetryLoadingOnError: Bool = false
    @Published var subscriptionActive: Bool = false
    
    @Published var weeklyProduct: Product?
    @Published var monthlyProduct: Product?
    
    
    init() {
        Task {
            await refresh()
        }
    }
    
    func refresh() async {
        let weeklyProductID = ConstantsHelper.weeklyProductID
        let monthlyProductID = ConstantsHelper.monthlyProductID
        
        do {
            let products = try await IAPManager.fetchProducts(productIDs: [
                weeklyProductID,
                monthlyProductID
            ])
            
            await MainActor.run {
                self.weeklyProduct = products.first(where: {$0.id == weeklyProductID})
                self.monthlyProduct = products.first(where: {$0.id == monthlyProductID})
            }
        } catch {
            // TODO: Handle errors
            print("Error fetching products in UltraViewModel... \(error)")
        }
    }
    
//    func restore() async throws {
//        defer {
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//        }
//        
//        DispatchQueue.main.async {
//            self.isLoading = true
//        }
//        
//        try await AppStore.sync()
//        
//        
//    }
    
//    func purchase(validSubscription: ValidSubscriptions) async {
//        let authToken: String
//        do {
//            authToken = try await AuthHelper.ensure()
//        } catch {
//            // TODO: Handle errors
//            print("Error ensuring authToken with AuthHelper... \(error)")
//            return
//        }
//        
//        defer {
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//        }
//        
//        DispatchQueue.main.async {
//            self.isLoading = true
//        }
//        
//        do {
//            guard let json = try await IAPHTTPSClient.getIAPStuffFromServer(authToken: authToken) else {
//                // TODO: Handle errors
//                DispatchQueue.main.async {
//                    self.showLoadingErrorAlert = true
//                }
//                
//                print("Could not unwrap json from getting IAP stuff from server with IAPHTTPSClient in purchase in UltraViewModel!")
//                return
//            }
//            
//            try await handleGetIAPStuffFromServerResponse(json, productID: validSubscription.rawValue)
//        } catch {
//            // TODO: Handle errors
//            DispatchQueue.main.async {
//                self.showLoadingErrorAlert = true
//            }
//            
//            print("Error getting IAP stuff from server with IAPHTTPSClient in purchase in UltraViewModel... \(error)")
//        }
//    }
//    
//    private func handleGetIAPStuffFromServerResponse(_ json: [String: Any], productID: String) async throws {
//        guard let success = json["Success"] as? Int else { showGeneralIAPErrorAndUnhide(); return }
//
//        if success == 1 {
//            guard let body = json["Body"] as? [String: Any] else { showGeneralIAPErrorAndUnhide(); return }
////            guard let sharedSecret = body["sharedSecret"] as? String else { showGeneralIAPErrorAndUnhide(); return }
//            guard let productIDs = body["productIDs"] as? [String] else { showGeneralIAPErrorAndUnhide(); return }
//            
//            if productIDs.count > 0 {
//                // Get products from server
//                let products = try await IAPManager.fetchProducts(productIDs: productIDs)
//                
//                guard let productToPurchase: Product = products.first(where: {$0.id == productID}) else {
//                    showGeneralRetryableIAPErrorAndUnhide()
//                    return
//                }
//                
//                guard let authToken = try? await AuthHelper.ensure() else {
//                    // If the authToken is nil, show an error alert that the app can't connect to the server and return
//                    showGeneralIAPErrorAndUnhide()
//                    
//                    return
//                }
//                
//                // Purchase the product!
//                let transaction = try await IAPManager.purchase(productToPurchase)
//                
//                // Update tenjin
//                TenjinSDK.transaction(
//                    withProductName: productToPurchase.displayName,
//                    andCurrencyCode: "USD",
//                    andQuantity: 1,
//                    andUnitPrice: NSDecimalNumber(decimal: productToPurchase.price))
//                
//                // Register the transaction ID with the server
//                try await premiumUpdater.registerTransaction(authToken: authToken, transactionID: transaction.id)
//            }
//        }
//    }
    
//    private func showGeneralRetryableIAPErrorAndUnhide() {
//        // TODO: Handle errors better
//        shouldRetryLoadingOnError = true
//        showGeneralIAPErrorAndUnhide()
//    }
//    
//    private func showGeneralIAPErrorAndUnhide() {
//        // TODO: Handle errors better
//        DispatchQueue.main.async {
//            self.showLoadingErrorAlert = true
//        }
//    }
    
}


////
////  UltraViewModel.swift
////  Barback
////
////  Created by Alex Coundouriotis on 10/7/23.
////
//
//import Foundation
//import StoreKit
//import SwiftUI
//import TenjinSDK
//
//class UltraViewModel: ObservableObject {
//    
//    @Published var isLoading: Bool = false
//    @Published var showLoadingErrorAlert: Bool = false
//    @Published var shouldRetryLoadingOnError: Bool = false
//    @Published var subscriptionActive: Bool = false
//    
//    var premiumUpdater: PremiumUpdater
//    
//    
//    init(premiumUpdater: PremiumUpdater) {
//        self.premiumUpdater = premiumUpdater
//    }
//    
//    func restore() async throws {
//        defer {
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//        }
//        
//        DispatchQueue.main.async {
//            self.isLoading = true
//        }
//        
//        try await AppStore.sync()
//        
//        
//    }
//    
//    func purchase(subscriptionPeriod: SubscriptionPeriod) async {
//        let authToken: String
//        do {
//            authToken = try await AuthHelper.ensure()
//        } catch {
//            // TODO: Handle errors
//            print("Error ensuring authToken with AuthHelper... \(error)")
//            return
//        }
//        
//        defer {
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//        }
//        
//        DispatchQueue.main.async {
//            self.isLoading = true
//        }
//        
//        do {
//            guard let json = try await IAPHTTPSClient.getIAPStuffFromServer(authToken: authToken) else {
//                // TODO: Handle errors
//                DispatchQueue.main.async {
//                    self.showLoadingErrorAlert = true
//                }
//                
//                print("Could not unwrap json from getting IAP stuff from server with IAPHTTPSClient in purchase in UltraViewModel!")
//                return
//            }
//            
//            try await handleGetIAPStuffFromServerResponse(json, subscriptionPeriod: subscriptionPeriod)
//        } catch {
//            // TODO: Handle errors
//            DispatchQueue.main.async {
//                self.showLoadingErrorAlert = true
//            }
//            
//            print("Error getting IAP stuff from server with IAPHTTPSClient in purchase in UltraViewModel... \(error)")
//        }
//    }
//    
//    private func handleGetIAPStuffFromServerResponse(_ json: [String: Any], subscriptionPeriod: SubscriptionPeriod) async throws {
//        guard let success = json["Success"] as? Int else { showGeneralIAPErrorAndUnhide(); return }
//
//        if success == 1 {
//            guard let body = json["Body"] as? [String: Any] else { showGeneralIAPErrorAndUnhide(); return }
////            guard let sharedSecret = body["sharedSecret"] as? String else { showGeneralIAPErrorAndUnhide(); return }
//            guard let productIDs = body["productIDs"] as? [String] else { showGeneralIAPErrorAndUnhide(); return }
//            
//            if productIDs.count > 0 {
//                // Get products from server
//                let products = try await IAPManager.fetchProducts(productIDs: productIDs)
//                
//                guard let productToPurchase: Product = products.first(where: {IAPManager.getSubscriptionPeriod(product: $0) == subscriptionPeriod}) else {
//                    showGeneralRetryableIAPErrorAndUnhide()
//                    return
//                }
//                
//                guard let authToken = try? await AuthHelper.ensure() else {
//                    // If the authToken is nil, show an error alert that the app can't connect to the server and return
//                    showGeneralIAPErrorAndUnhide()
//                    
//                    return
//                }
//                
//                // Purchase the product!
//                let transaction = try await IAPManager.purchase(productToPurchase)
//                
//                // Update tenjin
//                TenjinSDK.transaction(
//                    withProductName: productToPurchase.displayName,
//                    andCurrencyCode: "USD",
//                    andQuantity: 1,
//                    andUnitPrice: NSDecimalNumber(decimal: productToPurchase.price))
//                
//                // Register the transaction ID with the server
//                try await premiumUpdater.registerTransaction(authToken: authToken, transactionID: transaction.id)
//            }
//        }
//    }
//    
//    private func showGeneralRetryableIAPErrorAndUnhide() {
//        // TODO: Handle errors better
//        shouldRetryLoadingOnError = true
//        showGeneralIAPErrorAndUnhide()
//    }
//    
//    private func showGeneralIAPErrorAndUnhide() {
//        // TODO: Handle errors better
//        DispatchQueue.main.async {
//            self.showLoadingErrorAlert = true
//        }
//    }
//    
//}
