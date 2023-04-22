//
//  SceneDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // TODO: - Remove these!
//        #if DEBUG
//        UserDefaults.standard.set(false, forKey: Constants.userDefaultHasFinishedIntro)
//        #endif
        
        // Set initial view controller
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultHasFinishedIntro) {

            // Get window from windowScene
            guard let windowScene = scene as? UIWindowScene else { return }
            let window = UIWindow(windowScene: windowScene)
            
            // Create StackedPresentingNavigationController to present intro
            let spnc = StackedPresentingNavigationController()
            spnc.stackedPresentationSpecification = IntroPresentationSpecification()
            spnc.onEmpty = { navigationController in
                // Load UltraViewController and set from start
                let uvc = UltraViewController()
                uvc.fromStart = true
                
                // Set userDefaultHasFinishedIntro to true when uesr finishes the intro
                UserDefaults.standard.set(true, forKey: Constants.userDefaultHasFinishedIntro)
                
                // Push to UltraViewController
                navigationController.pushViewController(uvc, animated: true)
            }
            
            // Set window's rootViewController to StackedPresentingNavigationController
            window.rootViewController = spnc
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

