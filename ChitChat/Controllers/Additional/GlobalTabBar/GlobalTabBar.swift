//
//  BottomTabBar.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/23/23.
//

import UIKit

class GlobalTabBar: UITabBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        itemPositioning = .centered
        itemSpacing = 0
        itemWidth = 0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        
        sizeThatFits.height += 28
        
        return sizeThatFits
    }
}
