//
//  PremiumEssayTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/14/23.
//

import UIKit

class PremiumEssayTableViewCellSource: TableViewCellSource {
    
    var reuseIdentifier: String = Registry.Essay.View.Table.Cell.premium.reuseID
    
    var delegate: EssayPremiumTableViewCellDelegate
    
    init(delegate: EssayPremiumTableViewCellDelegate) {
        self.delegate = delegate
    }

}
