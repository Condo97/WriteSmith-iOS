//
//  PremiumEssayTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/14/23.
//

import UIKit

class PremiumEssayTableViewCellSource: CellSource {
    
    var collectionViewCellReuseIdentifier: String?
    var tableViewCellReuseIdentifier: String? = Registry.Essay.View.Table.Cell.premium.reuseID
    
    var delegate: EssayPremiumTableViewCellDelegate
    
    init(delegate: EssayPremiumTableViewCellDelegate) {
        self.delegate = delegate
    }

}
