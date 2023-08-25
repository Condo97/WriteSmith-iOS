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
    
<<<<<<< HEAD
    override func loadWithSource(_ source: TableViewCellSource) {
=======
    override func loadWithSource(_ source: CellSource) {
>>>>>>> 45042808df3fc72a7d9204aef334f518932580b8
        super.loadWithSource(source)
        
        if let loadingSource = source as? LoadingTableViewCellSource {
            // Load bubbleImageView with aiChatBubbleColor tint and loadingImageView with the loadingDots gif
            bubbleImageView.image = BubbleImageMaker.makeBubbleImage(userSent: false)
            bubbleImageView.tintColor = Colors.aiChatBubbleColor
            
<<<<<<< HEAD
=======
            if let loadingChatSource = loadingSource as? LoadingChatTableViewCellSource {
                loadingChatSource.view = self
            }
            
>>>>>>> 45042808df3fc72a7d9204aef334f518932580b8
            // TODO: Set profileImageView dynamically
        }
    }
    
}
