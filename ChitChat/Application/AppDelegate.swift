//
//  AppDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import UIKit
import CoreData
import GoogleMobileAds
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        if UserDefaults.standard.bool(forKey: Constants.userDefaultNotFirstLaunch) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let center = UNUserNotificationCenter.current()
            UNUserNotificationCenter.current().delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { (granted, error) in
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//                    DispatchQueue.main.async {
                        TenjinSDK.getInstance("UN4PPH4ZU5Z3S6BDDJZZCXLPPFFJ5XLP", andSharedSecret: Private.sharedSecret)
                        TenjinSDK.connect()
                        TenjinSDK.debugLogs()
                        TenjinSDK.sendEvent(withName: "test_event")
//                    }
                })
            })
//        }
        }
        
        UIApplication.shared.registerForRemoteNotifications() // Is this google ads or tenjin?
        
        // Setup Google Mobile Ads
        GADMobileAds.sharedInstance().start()
        
        // If no authToken, register the user and update the authToken in UserDefaults
        AuthHelper.ensure(completion: nil)
        
        // Update imported constants
        ConstantsHelper.update()
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        // Do migration if necessary TODO: Should it be done like this? I mean the migration functions won't do anything if it's the user's first launch, but should they even be called in the first place and how would I prevent them from being called if so?
        if !UserDefaults.standard.bool(forKey: Constants.Migration.userDefaultStoredV3_5MigrationComplete) {
            Task {
                await V3_5MigrationHandler.migrate()
                
                UserDefaults.standard.set(true, forKey: Constants.Migration.userDefaultStoredV3_5MigrationComplete)
            }
        }
        
        if !UserDefaults.standard.bool(forKey: Constants.Migration.userDefaultStoredV4MigrationComplete) {
            Task {
                try await V4MigrationHandler.migrate()
                
                UserDefaults.standard.set(true, forKey: Constants.Migration.userDefaultStoredV4MigrationComplete)
            }
        }
        
        // Set latestVersionMigrationComplete in UserDefaults
        if let version = version {
            UserDefaults.standard.set(version, forKey: Constants.Migration.userDefaultStoredLatestVersionMigrationComplete)
        }
        
        
        return true
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentCloudKitContainer(name: "ChitChat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("SDKJHFJLDSHFJKLSDHLKFHSDJK")
    }
    
}

