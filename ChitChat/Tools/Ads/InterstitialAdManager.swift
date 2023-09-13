//
//  InterstitialAdManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/12/23.
//

import Foundation
import GoogleMobileAds
import UIKit

class InterstitialAdManager: NSObject {
    
    // Instance
    public static var instance: InterstitialAdManager = {
        InterstitialAdManager(interstitialAdUnitID: Private.interstitialID)
    }()
    
    
    // Instance variables
    private var interstitial: GADInterstitialAd?
    
    // Initialization variables
    private var interstitialAdUnitID: String
    
    
    init(interstitialAdUnitID: String) {
        self.interstitialAdUnitID = interstitialAdUnitID
    }
    
    func loadAd() async {
        // Return immediately if there is already an ad loaded
        guard interstitial == nil else {
            return
        }
        
        // Load an ad
        let request = GADRequest()
        
        do {
            interstitial = try await GADInterstitialAd.load(
                withAdUnitID: interstitialAdUnitID,
                request: request)
            interstitial?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load interstitial ad with error: \(error)")
        }
    }
    
    func showAd(from rootViewController: UIViewController) async {
        await loadAd()
        
        if let interstitial = interstitial {
            DispatchQueue.main.async {
                interstitial.present(fromRootViewController: rootViewController)
            }
        }
    }
    
}

extension InterstitialAdManager: GADFullScreenContentDelegate {
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task {
            interstitial = nil
            await loadAd()
        }
    }
    
}
