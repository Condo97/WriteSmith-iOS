////
////  ShareViewHelper.swift
////  ChitChat
////
////  Created by Alex Coundouriotis on 4/25/23.
////
//
//import Foundation
//import UIKit
//
//class ShareViewHelper: Any {
//    
//    static func share(_ text: String, viewController: UIViewController) {
//        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: [])
//        
//        viewController.present(activityVC, animated: true)
//    }
//    
//    static func shareApp(viewController: UIViewController) {
//        let activityVC = UIActivityViewController(activityItems: [UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredShareURL) ?? ""], applicationActivities: [])
//        
//        viewController.present(activityVC, animated: true)
//    }
//    
//}
