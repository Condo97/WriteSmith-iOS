//
//  ChatTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var chatText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
