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
        
        /* Set TableView Manager */
        rootView.tableView.manager = sourcedTableViewManager
        
        /* Setup Logo imageView and image */
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 140, height: 80))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "logoImage")
        imageView.image = image
        
        navigationItem.titleView = imageView
        
        /* Set NavigationController Tint Color */
        navigationController?.navigationBar.tintColor = Colors.elementTextColor
        
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
