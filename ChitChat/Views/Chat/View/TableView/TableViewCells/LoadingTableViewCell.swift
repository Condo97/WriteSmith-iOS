//
//  LoadingChatTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/26/23.
//

import Foundation

class LoadingTableViewCell: UITableViewCell, LoadableTableViewCell {
    
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var loadingView: UIView!
    
    func loadWithSource(_ source: TableViewCellSource) {
        if let loadingSource = source as? LoadingTableViewCellSource {
            if loadingSource.pulsatingDotsAnimation == nil {
                loadingSource.pulsatingDotsAnimation = PulsatingDotsAnimation.createAnimation(frame: self.loadingView.bounds, amount: 4, duration: 1, color: loadingSource.dotColor)
            }
            
            loadingSource.pulsatingDotsAnimation?.start()
            loadingView.addSubview(loadingSource.pulsatingDotsAnimation!.dotsView)
            
        }
        
        // Load bubbleImageView with aiChatBubbleColor tint and loadingImageView with the loadingDots gif
        bubbleImageView.image = BubbleImageMaker.makeBubbleImage(userSent: false)
        bubbleImageView.tintColor = Colors.aiChatBubbleColor
        
        // TODO: Set profileImageView dynamically
    }
    
}
