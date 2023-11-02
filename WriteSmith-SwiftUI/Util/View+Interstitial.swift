////
////  View+Interstitial.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 10/30/23.
////
//
//import SwiftUI
//import UIKit
//
//extension View {
//    
//    func interstitial(disabled: Binding<Bool>, isPresented: Binding<Bool>, manager: GADInterstitialCoordinator, adViewControllerRepresentable: GADBlankAdContainerViewController) -> some View {
////        let adViewControllerRepresentable = GADInterstitialViewControllerRepresentable()
//        
//        var adViewControllerRepresentableView: some View {
//            adViewControllerRepresentable
//                .frame(width: .zero, height: .zero)
//        }
//        
//        return ZStack {
//            Color.clear
//                .onAppear {
//                    manager.loadAd()
//                }
//                .onChange(of: disabled.wrappedValue, perform: { newValue in
//                    if !newValue {
//                        manager.loadAd()
//                    }
//                })
//                .background(
//                    adViewControllerRepresentable
//                        .frame(width: .zero, height: .zero)
//                )
//                .onChange(of: isPresented.wrappedValue, perform: { newValue in
//                    if newValue && !disabled.wrappedValue {
//                        manager.showAd(from: adViewControllerRepresentable.viewController)
//                    }
//                    
//                    isPresented.wrappedValue = false
//                    
////                    manager.loadAd()
//                })
//            
//            self
//        }
//    }
//    
//}
