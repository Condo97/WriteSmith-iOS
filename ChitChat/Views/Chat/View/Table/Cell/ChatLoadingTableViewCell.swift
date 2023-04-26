//
//  LoadingChatTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/26/23.
//

import Foundation

class ChatLoadingTableViewCell: LoadingTableViewCell {
    
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func loadWithSource(_ source: TableViewCellSource) {
        super.loadWithSource(source)
        
        if let loadingSource = source as? LoadingTableViewCellSource {
            // Load bubbleImageView with aiChatBubbleColor tint and loadingImageView with the loadingDots gif
            bubbleImageView.image = BubbleImageMaker.makeBubbleImage(userSent: false)
            bubbleImageView.tintColor = Colors.aiChatBubbleColor
            
            // TODO: Set profileImageView dynamically
        }
    }
    
}
