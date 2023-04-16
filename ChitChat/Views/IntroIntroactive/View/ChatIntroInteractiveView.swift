//
//  ChatIntroInteractiveView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/24/23.
//

import UIKit

class ChatIntroInteractiveView: UIView {

    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var bottomTitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var chatTableView: ChatTableView!
    @IBOutlet weak var choiceTableView: ChatTableView!
    
    @IBOutlet weak var choiceTableViewBackgroundView: RoundedView!
    
    @IBOutlet weak var choiceTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var delegate: IntroInteractiveViewDelegate?
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        delegate?.nextButtonPressed()
    }
    
}
