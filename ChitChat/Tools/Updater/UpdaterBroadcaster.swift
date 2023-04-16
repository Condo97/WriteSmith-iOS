//
//  PremiumBroadcaster.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/13/23.
//

import Foundation

class UpdaterBroadcaster<T: Updater> {
    /***
     On full update, it sends full update to the structure updater, then on response it sends full update to all the structure updater delegates in updaters[]
     */
    
    internal lazy var updater: Updater = {
        var psu = T()
        psu.updaterDelegate = self
        return psu
    }()!
    
    internal var updaters: [IdentifiableObject<Any>] = []
    
    internal var lastID: Int = 0
    
    func addObserver(_ updaterDelegate: Any) -> Int {
        // Configure observer
        let observer = IdentifiableObject(id: lastID, t: updaterDelegate)
        observer.id = lastID
        lastID += 1
        
        // Append to observers
        updaters.append(observer)
        
        return observer.id
    }
    
    func removeObserver(id: Int) {
        // Remove observer
        updaters.removeAll(where: { $0.id == id })
    }
    
    func fullUpdate() {
        fullUpdate(completion: nil)
    }
    
    func fullUpdate(completion: (()->Void)?) {
        updater.fullUpdate(completion: {
            completion?()
        })
    }
    
}
