//
//  CreationTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/25/23.
//

import Foundation

protocol CreationExploreTableViewCellDelegate {
    func copyButtonPressed(_ sender: Any, overlayButton: RoundedButton?, text: String)
    func shareButtonPressed(_ sender: Any, text: String)
    func upgradeButtonPressed(_ sender: Any)
}

class CreationExploreTableViewCell: UITableViewCell, LoadableCell {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var copyButton: RoundedButton!
    @IBOutlet weak var copiedButtonOverlay: RoundedButton!
    @IBOutlet weak var shareButton: RoundedButton!
    @IBOutlet weak var upgradeButton: RoundedButton!
    
    var delegate: CreationExploreTableViewCellDelegate?
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        delegate?.copyButtonPressed(sender, overlayButton: copiedButtonOverlay, text: textView.text)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        delegate?.shareButtonPressed(sender, text: textView.text)
    }
    
    @IBAction func upgradeButtonPressed(_ sender: Any) {
        delegate?.upgradeButtonPressed(sender)
    }
    
    func loadWithSource(_ source: CellSource) {
        if let creationSource = source as? CreationExploreTableViewCellSource {
            textView.text = creationSource.text
            delegate = creationSource.delegate
            
            upgradeButton.isHidden = creationSource.upgradeButtonIsHidden
        }
    }
    
}
