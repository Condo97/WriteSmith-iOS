//
//  SettingsTableViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/10/23.
//

import UIKit
import SafariServices

class SettingsViewController: ManagedTableViewInViewController {
    
    let ultraPurchaseSection = 0
    let settingsSection = 1
    
    var restorePressed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup Logo imageView and image */
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 140, height: 80))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "logoImage")
        imageView.image = image
        
        navigationItem.titleView = imageView
        
        /* Set NavigationController Tint Color */
        navigationController?.navigationBar.tintColor = Colors.elementTextColor
        
        /* Loop through sources, delete any TieredVisibilityCellSource where shouldShowOnPremium == false */
        var i = 0
        var j = 0
        while i < sourcedTableViewManager.sources.count {
            while j < sourcedTableViewManager.sources[i].count {
                let source = sourcedTableViewManager.sources[i][j]
                
                if let tieredVisibilitySource = source as? TieredVisibilityCellSource {
                    if (tieredVisibilitySource.shouldShowOnFree && PremiumHelper.get()) || (tieredVisibilitySource.shouldShowOnPremium && !PremiumHelper.get()) {
                        // Should now show this source, so remove it from sources
                        
                        sourcedTableViewManager.sources[i].remove(at: j)
                    } else {
                        j += 1
                    }
                } else {
                    j += 1
                }
            }
            
            if sourcedTableViewManager.sources[i].count == 0 {
                sourcedTableViewManager.sources.remove(at: i)
            } else {
                i += 1
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        restorePressed = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Set shouldRestoreFromSettings to true in UltraPurchaesViewController if restore was pressed
        if segue.identifier == "toUltraPurchase" && restorePressed {
            if let detailVC = segue.destination as? UltraViewController {
                detailVC.shouldRestoreFromSettings = true
            }
        }
    }
    
    func goToUltraPurchase() {
        UltraViewControllerPresenter.presentOnTop(animated: true)
    }
    
}
