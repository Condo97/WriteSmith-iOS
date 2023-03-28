//
//  SettingsTableViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/10/23.
//

import UIKit
import SafariServices

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var restoreLabel: UILabel!
    
    @IBOutlet weak var giftImageView: UIImageView!
    
    var restorePressed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "logoImage")
        navigationItem.titleView = UIImageView(image: image)
        
        giftImageView.image = UIImage.gifImageWithName("giftGif")
        
        // Load label text
        let shareText = NSMutableAttributedStringBuilder()
            .bold("Share App")
            .normal(" With Friends")
            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
            .get()
        shareLabel.attributedText = shareText
        
        let termsText = NSMutableAttributedStringBuilder("Terms of Use")
            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
            .get()
        termsLabel.attributedText = termsText;
        
        let privacyText = NSMutableAttributedStringBuilder("Privary Policy")
            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
            .get()
        privacyLabel.attributedText = privacyText
        
        let restoreText = NSMutableAttributedStringBuilder("Restore Purchases")
            .addGlobalAttribute(.foregroundColor, value: Colors.aiChatTextColor)
            .get()
        restoreLabel.attributedText = restoreText
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        restorePressed = false
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Colors.userChatTextColor
        header.textLabel?.font = UIFont(name: Constants.primaryFontNameBold, size: 25)
        header.textLabel?.frame = CGRect(x: view.bounds.minX + 24, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            return 0
        }
        
        if section == 0 && UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            return 0
        }
        
        return tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            return 0
        }
        
        return tableView.estimatedSectionFooterHeight
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) && section == 0 {
            return 0
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "toUltraPurchase", sender: nil)
        }
        
        if indexPath.row == 0 {
            let activityVC = UIActivityViewController(activityItems: [UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) ?? ""], applicationActivities: [])
            
            present(activityVC, animated: true)
        } else if indexPath.row == 1 {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.termsAndConditions)")!
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        } else if indexPath.row == 2 {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.privacyPolicy)")!
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        } else if indexPath.row == 3 {
            restorePressed = true
            performSegue(withIdentifier: "toUltraPurchase", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Set shouldRestoreFromSettings to true in UltraPurchaesViewController if restore was pressed
        if segue.identifier == "toUltraPurchase" && restorePressed {
            if let detailVC = segue.destination as? UltraPurchaseViewController {
                detailVC.shouldRestoreFromSettings = true
            }
        }
    }
    
}
