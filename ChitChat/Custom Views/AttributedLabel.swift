//
//  AttributedLabel.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/16/23.
//

import UIKit

class AttributedLabel: UILabel {
    
    @IBInspectable open var setTextColor: UIColor = .white
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
    }
}
