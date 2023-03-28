//
//  ChatViewController+GAD.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/19/23.
//

import Foundation
import GoogleMobileAds

extension ChatViewController: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present full screen content")
        
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content")
        
        loadGAD()
    }
}


extension ChatViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        DispatchQueue.main.async {
            if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                self.adViewHeightConstraint.constant = 50.0
                self.adView.alpha = 1.0
                self.adShadowView.isHidden = false
                
                bannerView.translatesAutoresizingMaskIntoConstraints = false
                self.adView.addSubview(bannerView)
                self.adView.addConstraints([NSLayoutConstraint(item: bannerView, attribute: .centerY, relatedBy: .equal, toItem: self.adView, attribute: .centerY, multiplier: 1, constant: 0), NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: self.adView, attribute: .centerX, multiplier: 1, constant: 0)])
                
                DispatchQueue.main.async {
//                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: false)
                }
            }
        }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        
        adView.alpha = 0.0
        adViewHeightConstraint.constant = 0.0
        adShadowView.isHidden = true
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}
