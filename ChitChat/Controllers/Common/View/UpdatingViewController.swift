//
//  PremiumUpdaterObservingViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/14/23.
//

import UIKit

class UpdatingViewController: UIViewController {
    
    var premiumUpdaterDelegateID: Int?
    var remainingUpdaterDelegateID: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Add self as premiumUpdater and remainingUpdater delegate if necessary */
        if premiumUpdaterDelegateID == nil {
            premiumUpdaterDelegateID = PremiumUpdater.sharedBroadcaster.addObserver(self)
        }
        
        if remainingUpdaterDelegateID == nil {
            remainingUpdaterDelegateID = GeneratedChatsRemainingUpdater.sharedBroadcaster.addObserver(self)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Call updatePremium with stored premium property for initial update */
        updatePremium(isPremium: PremiumHelper.get())
        
        /* Do full premium and remaining update */
        PremiumUpdater.sharedBroadcaster.fullUpdate()
        GeneratedChatsRemainingUpdater.sharedBroadcaster.fullUpdate()
        
    }

}
