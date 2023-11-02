//
//  GADBlankAdContainerViewController.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/17/23.
//

import GoogleMobileAds
import SwiftUI

class GADInterstitialCoordinator: NSObject, GADFullScreenContentDelegate {
    
    let interstitialID: String
    
    
    private var interstitial: GADInterstitialAd?
    
    init(interstitialID: String) {
        self.interstitialID = interstitialID
    }
    
    func loadAd() {
        GADInterstitialAd.load(
            withAdUnitID: interstitialID, request: GADRequest()
        ) { ad, error in
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        interstitial = nil
//        loadAd()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print(error)
    }
    
    func showAd(from viewController: UIViewController) {
        guard let interstitial = interstitial else {
//            loadAd()
            print("Ad wasn't ready")
            return
        }
        
        interstitial.present(fromRootViewController: viewController)
    }
}
