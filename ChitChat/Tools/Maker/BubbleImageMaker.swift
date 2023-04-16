//
//  BubbleImageMaker.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/21/23.
//

import Foundation

class BubbleImageMaker {
    static func makeBubbleImage(userSent: Bool) -> UIImage {
        let name: String
        if userSent {
            name = "chat_bubble_sent"
        } else {
            name = "chat_bubble_received"
        }
        
        let image = UIImage(named: name)! // The names must be correct!
        return image
            .resizableImage(withCapInsets:
                                UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                            resizingMode: .stretch)
            .withRenderingMode(.alwaysTemplate)
    }
}
