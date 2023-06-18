//
//  StructureUpdaterDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/15/23.
//

import Foundation

protocol Updater {
    
    var updaterDelegate: Any? { get set }
    
    init()
    
    func forceUpdate() async throws
    
}
