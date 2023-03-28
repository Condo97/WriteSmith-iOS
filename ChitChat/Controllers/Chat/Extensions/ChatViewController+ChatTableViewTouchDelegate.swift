//
//  ChatViewController+ChatTableView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

extension ChatViewController: ChatTableViewTouchDelegate {
    
    func tappedIndexPath(_ indexPath: IndexPath, tableView: UITableView, touch: UITouch) {
        
        guard let chatCell = tableView.cellForRow(at: indexPath) as? ChatTableViewCell else {
            return
        }
                
        if !isLongPressForShare {
            // Make sure cell has chatText
            if chatCell.chatText != nil {
                
                // Show copy text at location
                if let attributedText = chatCell.chatText.attributedText {
                    // Copy to Pasteboard
                    var text = attributedText.string
                    
                    //TODO: - Make the footer text an option in settings instead of disabling it for premium entirely
                    if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                        if let shareURL = UserDefaults.standard.string(forKey: Constants.userDefaultStoredShareURL) {
                            text = "\(text)\n\n\(Constants.copyFooterText)\n\(shareURL)"
                        } else {
                            text = "\(text)\n\n\(Constants.copyFooterText)"
                        }
                    }
                    
                    UIPasteboard.general.string = text
                    
                    // Move label if too large
                    if chatCell.frame.height >= chatCell.copiedLabel.frame.height * 4 {
                        let touchLocationInCell = touch.location(in: chatCell.chatText)
                        let proposedY = touchLocationInCell.y - chatCell.copiedLabel.frame.height
                        let copiedLabelCenterY = chatCell.copiedLabel.frame.height / 2
                        let littleBuffer = (chatCell.frame.height - chatCell.chatText.frame.height) / 2
                        
                        // Okay I've got to do something about these calculations at some point
                        if proposedY <= chatCell.copiedLabel.frame.height * 1.2 - chatCell.copiedLabel.frame.height {
                            chatCell.copiedLabel.frame = CGRect(x: chatCell.copiedLabel.frame.minX, y: chatCell.copiedLabel.frame.height * 1.2 - copiedLabelCenterY + littleBuffer, width: chatCell.copiedLabel.frame.width, height: chatCell.copiedLabel.frame.height)
                        } else if proposedY >= chatCell.chatText.frame.height - chatCell.copiedLabel.frame.height * 1.2 - 2 * chatCell.copiedLabel.frame.height - littleBuffer  {
                            chatCell.copiedLabel.frame = CGRect(x: chatCell.copiedLabel.frame.minX, y: chatCell.chatText.frame.height - chatCell.copiedLabel.frame.height * 1.2 - chatCell.copiedLabel.frame.height / 2 + littleBuffer, width: chatCell.copiedLabel.frame.width, height: chatCell.copiedLabel.frame.height)
                        } else {
                            chatCell.copiedLabel.frame = CGRect(x: chatCell.copiedLabel.frame.minX, y: touchLocationInCell.y + copiedLabelCenterY, width: chatCell.copiedLabel.frame.width, height: chatCell.copiedLabel.frame.height)
                        }
                    } else {
                        chatCell.copiedLabel.frame = CGRect(x: 0, y: 0, width: chatCell.chatText.frame.width, height: chatCell.chatText.frame.height)
                    }
                    
                    // Animate Copy
                    UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
                        chatCell.copiedLabel.alpha = 1.0
                        chatCell.copiedBackgroundView.alpha = 1.0
                        
                        UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                            chatCell.copiedLabel.alpha = 0.0
                            chatCell.copiedBackgroundView.alpha = 0.0
                        })
                    })
                }
            }
        }
        
        isLongPressForShare = false
    }
}
