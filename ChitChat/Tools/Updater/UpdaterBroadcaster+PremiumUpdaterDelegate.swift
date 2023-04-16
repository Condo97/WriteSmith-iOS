//
//  UpdaterBroadcaster+PremiumUpdaterDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/15/23.
//

import Foundation

extension UpdaterBroadcaster: PremiumUpdaterDelegate {
    
    func updatePremium(isPremium: Bool) {
        for updater in updaters {
            if let premiumDelegate = updater.t as? PremiumUpdaterDelegate {
                premiumDelegate.updatePremium(isPremium: isPremium)
            }
        }
    }
    
//    func updatePremium(isPremium: Bool) {
//        for observer in StructureUpdaterBroadcaster.updaters {
//            observer.delegate.updatePremium(isPremium: isPremium)
//        }
//    }
//
//    func updateRemaining(remaining: Int) {
//        for observer in StructureUpdaterBroadcaster.updaters {
//            observer.delegate.updateRemaining(remaining: remaining)
//        }
//    }
    
}
