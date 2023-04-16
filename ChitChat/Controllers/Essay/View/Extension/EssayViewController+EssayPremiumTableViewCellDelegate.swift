//
//  EssayViewController+EssayPremiumTableViewCellDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

extension EssayViewController: EssayPremiumTableViewCellDelegate {
    func didPressPremiumButton(sender: Any, cell: EssayPremiumTableViewCell) {
        goToUltraPurchase()
    }
}
