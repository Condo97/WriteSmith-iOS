//
//  WriteSmith_SwiftUIApp.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/20/23.
//

import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI
import TenjinSDK

@main
struct WriteSmith_SwiftUIApp: App {
    
    @StateObject private var premiumUpdater: PremiumUpdater = PremiumUpdater()
    @StateObject private var remainingUpdater: RemainingUpdater = RemainingUpdater()
    
    @State private var isShowingIntroView: Bool
    
    
    init() {
        UIView.appearance().tintColor = UIColor(Colors.elementTextColor)
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Colors.buttonBackground)
        UIView.appearance(whenContainedInInstancesOf: [UIImagePickerController.self]).tintColor = UIColor(Colors.elementBackgroundColor)
        
        GADMobileAds.sharedInstance().start()
        
        self._isShowingIntroView = State(initialValue: !IntroManager.isIntroComplete)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isShowingIntroView {
                    IntroPresenterView(
                        premiumUpdater: premiumUpdater,
                        isShowing: $isShowingIntroView)
                    .transition(.move(edge: .bottom))
                    .zIndex(1.0)
                } else {
                    TabBar(
                        premiumUpdater: premiumUpdater,
                        remainingUpdater: remainingUpdater)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: isShowingIntroView)
            .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
            .onAppear {
                // Start Tenjin stuff
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { (granted, error) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                                //                    DispatchQueue.main.async {
                                TenjinSDK.getInstance("UN4PPH4ZU5Z3S6BDDJZZCXLPPFFJ5XLP", andSharedSecret: Keys.sharedSecret)
                                TenjinSDK.connect()
                                TenjinSDK.debugLogs()
                                TenjinSDK.sendEvent(withName: "test_event")
                                //                    }
                            })
                        }
                    })
        //        }
                }
            }
            .task {
                // Update important constants
                do {
                    try await ConstantsHelper.update()
                } catch {
                    // TODO: Handle errors
                    print("Error updating important constants in WriteSmith_SwiftUIApp... \(error)")
                }
            }
            .task {
                // Ensure authToken, otherwise return TODO: Handle errors
                let authToken: String
                do {
                    authToken = try await AuthHelper.ensure()
                } catch {
                    // TODO: Handle errors
                    print("Error unwrapping authToken in WriteSmith_SwiftUIApp... \(error)")
                    return
                }
                
                // Update premium
                do {
                    try await premiumUpdater.update(authToken: authToken)
                } catch {
                    // TODO: Handle errors
                    print("Error updating premium in WriteSmith_SwiftUIApp... \(error)")
                }
                
                // Update remaining
                do {
                    try await remainingUpdater.update(authToken: authToken)
                } catch {
                    // TODO: Handle errors
                    print("Error updating remaining in WriteSmith_SwiftUIApp... \(error)")
                }
            }
        }
    }
    
}
