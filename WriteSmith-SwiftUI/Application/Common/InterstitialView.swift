//
//  InterstitialView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/31/23.
//

import SwiftUI

struct InterstitialView: View {
    
    @State var interstitialID: String
    @Binding var disabled: Bool
    @Binding var isPresented: Bool
    
    
//    init(interstitialID: String, disabled: Binding<Bool>, isPresented: Binding<Bool>) {
//        self._disabled = disabled
//        self._isPresented = isPresented
////        self.gadInterstitialCoodrinator = GADInterstitialCoordinator(interstitialID: interstitialID)
//    }
    
    @State private var gadInterstitialCoodrinator: GADInterstitialCoordinator?// = GADInterstitialCoordinator(interstitialID: interstitialID)
    @State private var gadInterstitialViewControllerRepresentable: GADBlankAdContainerViewController = GADBlankAdContainerViewController()
    
    var body: some View {
        ZStack {
            Color.clear
                .onAppear {
                    gadInterstitialCoodrinator = GADInterstitialCoordinator(interstitialID: interstitialID)
                    
                    if !disabled {
                        gadInterstitialCoodrinator?.loadAd()
                    }
                }
                .onChange(of: disabled, perform: { newValue in
                    if !newValue {
                        gadInterstitialCoodrinator?.loadAd()
                    }
                })
                .background(
                    gadInterstitialViewControllerRepresentable
                        .frame(width: .zero, height: .zero)
                )
                .onChange(of: isPresented, perform: { newValue in
                    if newValue && !disabled {
                        gadInterstitialCoodrinator?.showAd(from: gadInterstitialViewControllerRepresentable.viewController)
                    }
                    
                    isPresented = false
                    
//                    manager.loadAd()
                })
        }
        .frame(width: .zero, height: .zero)
//        ZStack {
//            
//        }
//        .interstitial(
//            disabled: $disabled,
//            isPresented: $isPresented,
//            manager: gadInterstitialCoodrinator,
//            adViewControllerRepresentable: gadInterstitialViewControllerRepresentable)
    }
    
}

#Preview {
    
    struct ContentView: View {
        
        @State var isPresented: Bool = false
        
        var body: some View {
            InterstitialView(
                interstitialID: Keys.Ads.Interstitial.debug,
                disabled: .constant(false),
                isPresented: $isPresented)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                    isPresented = true
                })
            }
        }
        
    }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
//        isPresented = true
//    })
    
    return ContentView()
}
