//
//  SettingsTableViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/10/23.
//

import UIKit
import SafariServices

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var giftImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        giftImageView.image = UIImage.gifImageWithName("giftGif")
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Colors.chatTextColor
        header.textLabel?.font = UIFont(name: Constants.primaryFontNameBold, size: 25)
        header.textLabel?.frame = CGRect(x: view.bounds.minX + 24, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0
        }
        
        return tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "toUltraPurchase", sender: nil)
        }
        
        if indexPath.row == 0 {
            //TODO: - Share sheet
        } else if indexPath.row == 1 {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.privacyPolicy)")!
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        } else if indexPath.row == 2 {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let url = URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.termsAndConditions)")!
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        } else if indexPath.row == 3 {
            
        }
    }
    
}
