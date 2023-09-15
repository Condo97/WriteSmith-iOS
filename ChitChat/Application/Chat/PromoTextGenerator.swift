//
//  PromoTextGenerator.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/14/23.
//

import Foundation

class PromoTextGenerator {
    
    // TODO: Move this to a struct or something
    private static let promoText: [String] = [
        "Unlimited GPT-4 for 3 days free...",
        "GPT-4 is trained on 1T parameters...",
        "Unlimited messages & better responses...",
        "Homework Help, Essays & More...",
        "More accurate responses & help...",
        "Get more accurate responses...",
        "Try the latest AI model..."
    ]
    
    public static func randomUpgradeNowPromoText(differentThan promoText: String?) -> String {
        let randomUpgradeNowPromoText = randomUpgradeNowPromoText()
        return randomUpgradeNowPromoText != promoText ? randomUpgradeNowPromoText : Self.randomUpgradeNowPromoText(differentThan: promoText)
    }
    
    public static func randomUpgradeNowPromoText() -> String {
        promoText[Int.random(in: 0..<promoText.count)]
    }
    
}
