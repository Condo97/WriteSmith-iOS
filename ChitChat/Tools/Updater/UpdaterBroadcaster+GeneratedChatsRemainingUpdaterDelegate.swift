//
//  UpdaterBroadcaster+RemainingUpdaterDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/15/23.
//

import Foundation

extension UpdaterBroadcaster: GeneratedChatsRemainingUpdaterDelegate {
    
    func updateGeneratedChatsRemaining(remaining: Int) {
        for updater in updaters {
            if let generatedChatsRemainingDelegate = updater.t as? GeneratedChatsRemainingUpdaterDelegate {
                generatedChatsRemainingDelegate.updateGeneratedChatsRemaining(remaining: remaining)
            }
        }
    }
    
}
