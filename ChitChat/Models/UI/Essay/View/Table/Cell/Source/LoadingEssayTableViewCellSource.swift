//
//  LoadingEssayTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/14/23.
//

import UIKit

class LoadingEssayTableViewCellSource: TableViewCellSource {
    
    var reuseIdentifier: String = Registry.Essay.View.Table.Cell.loading.reuseID
    
    var pulsatingDotsAnimation: PulsatingDotsAnimation?
    var dotColor: UIColor
    
    convenience init() {
        self.init(dotColor: Colors.elementBackgroundColor)
    }
    
    init(dotColor: UIColor) {
        self.dotColor = dotColor
    }
    
}
