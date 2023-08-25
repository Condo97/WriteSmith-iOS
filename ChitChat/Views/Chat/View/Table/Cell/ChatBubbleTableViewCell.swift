//
//  ChatTableViewCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit

class ChatBubbleTableViewCell: UITableViewCell, Bounceable, LoadableCell {
    
    @IBOutlet weak var chatText: UILabel!
    @IBOutlet weak var copiedLabel: UILabel!
    @IBOutlet weak var copiedBackgroundView: UIView!
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
<<<<<<< HEAD

=======
    
>>>>>>> 45042808df3fc72a7d9204aef334f518932580b8
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
    
    /***
     Loading code that is used when dequing tableViewCell
     */
    func loadWithSource(_ source: CellSource) {
        // TODO: - Look at this again, is this a good place to load the cell, or should it be somewhere else since it references ChatTableViewCelLSource?
        if let chatSource = source as? ChatTableViewCellSource {
            chatSource.typingLabel = chatText
<<<<<<< HEAD
            
            if let typewriter = chatSource.typewriter, typewriter.isValid() {
                chatText.text = typewriter.typingString
=======
            chatSource.view = self
//            chatText.text = chatSource.chat.text
            
            if chatSource.isTyping {
                chatText.text = chatSource.typingText
>>>>>>> 45042808df3fc72a7d9204aef334f518932580b8
            } else {
                chatText.text = chatSource.chat.text
            }
            
<<<<<<< HEAD
=======
//            if let typewriter = chatSource.typewriter, typewriter.isValid() {
//                chatText.text = typewriter.typingString
//            } else {
//                chatText.text = chatSource.chat.text
//            }
            
>>>>>>> 45042808df3fc72a7d9204aef334f518932580b8
            setBubbleImage(isUser: chatSource.chat.sender == Constants.Chat.Sender.user)
        }
    }
    
}
