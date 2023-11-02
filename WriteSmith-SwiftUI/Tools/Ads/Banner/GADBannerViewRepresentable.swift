//
//  GADBannerViewRepresentable.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/17/23.
//

import GoogleMobileAds
import SwiftUI

struct GADBannerViewRepresentable: UIViewControllerRepresentable {
    
    let bannerID: String
    @Binding var isLoaded: Bool
    @Binding var adSize: CGSize
    
    
    @State private var viewWidth: CGFloat = .zero
    private let bannerView = GADBannerView()
//    private let adUnitID = Keys.gadBannerID
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let bannerViewController = BannerViewController()
        bannerView.adUnitID = bannerID
        bannerView.rootViewController = bannerViewController
        bannerView.delegate = context.coordinator
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerViewController.view.addSubview(bannerView)
        // Constrain GADBannerView to the bottom of the view.
//        NSLayoutConstraint.activate([
//            bannerView.bottomAnchor.constraint(
//                equalTo: bannerViewController.view.safeAreaLayoutGuide.bottomAnchor),
//            bannerView.centerXAnchor.constraint(equalTo: bannerViewController.view.centerXAnchor),
//        ])
        bannerViewController.delegate = context.coordinator
        
        return bannerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard viewWidth != .zero else { return }
        
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.load(GADRequest())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, isLoaded: $isLoaded, adSize: $adSize)
    }
    
    class Coordinator: NSObject, BannerViewControllerWidthDelegate, GADBannerViewDelegate
    {
        let parent: GADBannerViewRepresentable
        @Binding var isLoaded: Bool
        @Binding var adSize: CGSize
        
        init(_ parent: GADBannerViewRepresentable, isLoaded: Binding<Bool>, adSize: Binding<CGSize>) {
            self.parent = parent
            self._isLoaded = isLoaded
            self._adSize = adSize
        }
        
        // MARK: - BannerViewControllerWidthDelegate methods
        
        func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat) {
            parent.viewWidth = width
        }
        
        // MARK: - GADBannerViewDelegate methods
        
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("DID RECEIVE AD")
            adSize = bannerView.adSize.size
            isLoaded = true
        }
        
        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
            print("Test")
        }
        
        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
            isLoaded = false
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("DID NOT RECEIVE AD: \(error.localizedDescription)")
            isLoaded = false
        }
    }
}

#Preview {
    
    GADBannerViewRepresentable(bannerID: "ca-app-pub-3940256099942544/2934735716", isLoaded: .constant(true), adSize: .constant(.zero))
        .frame(width: 320, height: 50)
    
}
