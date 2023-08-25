//
//  SettingsPresentationSpecification.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import SafariServices
import UIKit

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
                    //TODO: Fix because it's deprecated
                    // Present on the topVC
                    UltraViewControllerPresenter.presentOnTop(animated: true)
                })
            ],
            [
                ImageTextTableViewCellSource(
                    didSelect: { tableView, indexPath in
                        // Show share app popup
                        ShareViewHelper.shareApp(viewController: UIApplication.shared.topmostViewController()!)
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
                        let url = URL(string: "\(HTTPSConstants.chitChatServerStaticFiles)\(HTTPSConstants.termsAndConditions)")!
                        
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
                        let url = URL(string: "\(HTTPSConstants.chitChatServerStaticFiles)\(HTTPSConstants.privacyPolicy)")!
                        
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
                        UltraViewControllerPresenter.presentOnTop(animated: true, shouldRestoreFromSettings: true)
                    },
                    image: SettingsImages().restorePurchases,
                    text: NSMutableAttributedStringBuilder()
                        .normal("Restore Purchases")
                        .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
                        .get())
            ]
        ])
        .register(Registry.Settings.View.Table.Cell.ultraPurchase)
        .register(Registry.Common.View.Table.Cell.imageText)
        .build(managedTableViewNibName: Registry.Common.View.managedInsetGroupedTableViewIn)
    
    init() {
        viewController = managedInsetGroupedTableViewInViewController
    }
    
}
