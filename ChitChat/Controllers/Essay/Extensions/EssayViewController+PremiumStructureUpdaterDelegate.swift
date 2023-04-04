//
//  EssayViewController+PremiumStructureUpdater.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/2/23.
//

import Foundation

extension EssayViewController: PremiumStructureUpdaterDelegate {
    
    func updatePremium(isPremium: Bool) {
        
    }
    
    func updateRemaining(remaining: Int) {
        
    }
    
    func switchToPremium() {
            // Remove 2 sections, add entry and any stored essays
            let premiumCount = essays.count
            let freeCount = essays.count + 1
            tableView.beginUpdates()
            tableView.deleteSections(IndexSet(integersIn: 0...freeCount), with: .none)
            tableView.insertSections(IndexSet(integersIn: 0...premiumCount), with: .none)
            tableView.endUpdates()
        }
        
        func switchToStandard() {
            // Remove entry and all stored essay sections, add 2 sections
            let premiumCount = essays.count
            let freeCount = essays.count + 1
            tableView.beginUpdates()
            tableView.deleteSections(IndexSet(integersIn: 0...premiumCount), with: .none)
            tableView.insertSections(IndexSet(integersIn: 0...freeCount), with: .none)
            tableView.endUpdates()
        }
    
}
