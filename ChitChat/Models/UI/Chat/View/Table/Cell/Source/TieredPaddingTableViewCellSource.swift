//
//  TieredPaddingTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/25/23.
//

import Foundation

class TieredPaddingTableViewCellSource: PaddingTableViewCellSource {
    
    var premiumPadding: CGFloat
    
    override init() {
        self.premiumPadding = UIConstants.premiumPaddingTableViewCellSourceHeight
        
        super.init()
    }
    
    init(defaultPadding: CGFloat, premiumPadding: CGFloat) {
        self.premiumPadding = premiumPadding
        
        super.init(padding: defaultPadding)
    }
    
    func getPadding(isPremium: Bool) -> CGFloat {
        return isPremium ? premiumPadding : padding
    }
    
}
