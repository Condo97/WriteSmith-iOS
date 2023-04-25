//
//  LoadingTableViewCellSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/21/23.
//

import Foundation

protocol LoadingTableViewCellSource: CellSource {
    
    var pulsatingDotsAnimation: PulsatingDotsAnimation? { get set }
    var dotColor: UIColor { get set }
    
    func setPulsatingDotsAnimation(_ pulsatingDotsAnimation: PulsatingDotsAnimation)
    
}
