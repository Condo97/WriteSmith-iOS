//
//  ChatGPTModelSelectionViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/10/23.
//

import Foundation

protocol ChatGPTModelSelectionViewDelegate {
    func didPressFreeModelButton()
    func didPressPaidModelButton()
    func didPressCloseButton()
}

class ChatGPTModelSelectionView: UIView {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var freeModelButton: RoundedButton!
    @IBOutlet weak var paidModelButton: RoundedButton!
    @IBOutlet weak var closeButton: RoundedButton!
    
    var delegate: ChatGPTModelSelectionViewDelegate?
    
    
    @IBAction func freeModelButtonPressed(_ sender: Any) {
        delegate?.didPressFreeModelButton()
    }
    
    @IBAction func paidModelButtonPressed(_ sender: Any) {
        delegate?.didPressPaidModelButton()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        delegate?.didPressCloseButton()
    }
    
}
