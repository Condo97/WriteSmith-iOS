//
//  UltraView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import Foundation

protocol UltraViewDelegate {
    
    func closeButtonPressed()
    func privacyPolicyButton()
    func termsAndConditionsButton()
    func restorePurchasesButton()
    
}

class UltraView: UIView {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var unleashLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var everythingElseView: UIView!
    
    @IBOutlet weak var ultraCheckLabel: UILabel!
    @IBOutlet weak var unlockCheckLabel: UILabel!
    @IBOutlet weak var removeAdsCheckLabel: UILabel!
    @IBOutlet weak var noCommitmentsCheckLabel: UILabel!
    
    @IBOutlet weak var weeklyRoundedView: RoundedView!
    @IBOutlet weak var weeklyText: UILabel!
    @IBOutlet weak var weeklyActivityView: UIActivityIndicatorView!
    
    @IBOutlet weak var monthlyRoundedView: RoundedView!
    @IBOutlet weak var monthlyText: UILabel!
    @IBOutlet weak var monthlyActivityView: UIActivityIndicatorView!
    
    var delegate: UltraViewDelegate?
    
    @IBAction func closeButton(_ sender: Any) {
        delegate?.closeButtonPressed()
    }
    
    @IBAction func privacyPolicyButton(_ sender: Any) {
        delegate?.privacyPolicyButton()
    }
    
    @IBAction func termsAndConditionsButton(_ sender: Any) {
        delegate?.termsAndConditionsButton()
    }
    
    @IBAction func restorePurchaseButton(_ sender: Any) {
        delegate?.restorePurchasesButton()
    }
    
}
