//
//  ChatTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var chatText: UILabel!
    @IBOutlet weak var copiedLabel: UILabel!
    @IBOutlet weak var copiedBackgroundView: UIView!
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
