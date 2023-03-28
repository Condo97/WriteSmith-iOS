//
//  PresentationSpecification.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

protocol PresentationSpecification {
    
    var introInteractiveViewControllers: [any LoadableViewController & IntroInteractiveViewController] { get }
    
}
