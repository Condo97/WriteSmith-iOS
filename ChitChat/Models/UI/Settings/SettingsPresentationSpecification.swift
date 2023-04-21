//
//  SettingsPresentationSpecification.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit
import SafariServices

class SettingsPresentationSpecification: PresentationSpecification {
    
    var viewController: UIViewController
    
    class SettingsImages {
        lazy var share = UIImage(systemName: Constants.Settings.View.Table.Cell.Settings.shareSystemImageName)!
        lazy var termsOfUse = UIImage(systemName: Constants.Settings.View.Table.Cell.Settings.termsOfUseSystemImageName)!
        lazy var privacyPolicy = UIImage(systemName: Constants.Settings.View.Table.Cell.Settings.privacyPolicySystemImageName)!
        lazy var restorePurchases = UIImage(systemName: Constants.Settings.View.Table.Cell.Settings.restorePurchasesSystemImageName)!
    }
    
    let managedInsetGroupedTableViewInViewController: SettingsViewController = SettingsViewController.Builder<SettingsViewController>(sourcedTableViewManager: SettingsSourcedTableViewManager())
        .set(sources: [
            [
                UltraPurchaseTableViewCellSource(didSelect: { tableView, indexPath in
//                    UIApplication.shared.connectedScenes.first?.inputViewController?.present(ultraPurchaseViewController, animated: true)
                    //TODO: Fix because it's deprecated
                    // Present on the topVC
                    UltraViewControllerPresenter.presentOnTop(animated: true)
                })
            ],
            [
                ImageTextTableViewCellSource(
                    didSelect: { tableView, indexPath in
                        // Create share activity VC
                        let activityVC = UIActivityViewController(activityItems: [UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) ?? ""], applicationActivities: [])
                        
                        // Present on the topVC
                        UIApplication.shared.topmostViewController()?.present(activityVC, animated: true)
                    },
                    image: SettingsImages().share,
                    text: NSMutableAttributedStringBuilder()
                        .bold("Share App")
                        .normal(" With Friends")
                        .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
                        .get()),
                ImageTextTableViewCellSource(
                    didSelect: { tableView, indexPath in
                        // Create safari view controller configuration
                        let config = SFSafariViewController.Configuration()
                        
                        // Automatically enter reader mode
                        config.entersReaderIfAvailable = true
                        
                        // Create url
                        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.termsAndConditions)")!
                        
                        // Instantiate safari view controller with url and configuration
                        let vc = SFSafariViewController(url: url, configuration: config)
                        
                        vc.modalPresentationStyle = .overFullScreen
                        
                        //TODO: Fix because it's deprecated
                        // Present on the topVC
                        UIApplication.shared.topmostViewController()?.present(vc, animated: true)
                    },
                    image: SettingsImages().termsOfUse,
                    text: NSMutableAttributedStringBuilder()
                        .normal("Terms of Use")
                        .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
                        .get()),
                ImageTextTableViewCellSource(
                    didSelect: { tableView, indexPath in
                        // Create safari view controller configuration
                        let config = SFSafariViewController.Configuration()
                        
                        // Automatically enter reader mode
                        config.entersReaderIfAvailable = true
                        
                        // Create url
                        let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.privacyPolicy)")!
                        
                        // Instantiate safari view controller with url and configuration
                        let vc = SFSafariViewController(url: url, configuration: config)
                        
                        vc.modalPresentationStyle = .overFullScreen
                        
                        //TODO: Fix because it's deprecated
                        // Present on the topVC
                        UIApplication.shared.topmostViewController()?.present(vc, animated: true)
                    },
                    image: SettingsImages().privacyPolicy,
                    text: NSMutableAttributedStringBuilder()
                        .normal("Privary Policy")
                        .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
                        .get()),
                ImageTextTableViewCellSource(
                    didSelect: { tableView, indexPath in
                        // Instantiate ultraPurchaseViewController
                        let ultraPurchaseViewController = UltraViewController()
                        
                        // Set modal presentation style as full screen
                        ultraPurchaseViewController.modalPresentationStyle = .overFullScreen
                        
                        // Set restore pressed to automatically restore once ultra view is loaded
                        ultraPurchaseViewController.restorePressed = true
                        
                        //TODO: Fix because it's deprecated
                        // Present on the topVC
                        UIApplication.shared.topmostViewController()?.present(ultraPurchaseViewController, animated: true)
                    },
                    image: SettingsImages().restorePurchases,
                    text: NSMutableAttributedStringBuilder()
                        .normal("Restore Purchases")
                        .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
                        .get())
            ]
        ])
        .register(Registry.Settings.View.TableView.Cell.ultraPurchase)
        .register(Registry.Common.View.TableView.Cell.imageText)
        .build()
    
    init() {
        viewController = managedInsetGroupedTableViewInViewController
    }
    
}
