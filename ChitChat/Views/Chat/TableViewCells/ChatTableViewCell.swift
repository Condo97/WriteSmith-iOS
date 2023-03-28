//
//  ChatTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit

class ChatTableViewCell: UITableViewCell, Bounceable, LoadableTableViewCell {
    
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
    
    func setBubbleImage(isUser: Bool) {
        if isUser {
            bubbleImageView.tintColor = Colors.userChatBubbleColor
        } else {
            bubbleImageView.tintColor = Colors.aiChatBubbleColor
        }
        
        bubbleImageView.image = BubbleImageMaker.makeBubbleImage(userSent: isUser)
    }
    
    // Bounce TableView Cell
    func beginBounce() {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { (_) in
            
        }
    }
    
    func endBounce() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    /***
     Loading code that is used when dequing tableViewCell
     */
    func loadWithSource(_ source: UITableViewCellSource) {
        // TODO: - Look at this again, is this a good place to load the cell, or should it be somewhere else since it references ChatTableViewCelLSource?
        if let chatSource = source as? ChatTableViewCellSource {
            chatSource.typingLabel = chatText
            
            if let typewriter = chatSource.typewriter, typewriter.isValid() {
                chatText.text = typewriter.typingString
            } else {
                chatText.text = chatSource.chat.text
            }
            
            setBubbleImage(isUser: chatSource.chat.sender == .user)
        }
    }
    
}
