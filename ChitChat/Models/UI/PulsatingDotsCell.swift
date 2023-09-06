//
//  PulsatingDotsCell.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/4/23.
//

import Foundation

protocol PulsatingDotsCell {
    
    var pulsatingDotsAnimation: PulsatingDotsAnimation? { get set }
    var pulsatingDotsBounds: CGRect { get set }
    
}
