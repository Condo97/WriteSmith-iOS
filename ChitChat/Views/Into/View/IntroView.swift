//
//  IntroView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/21/23.
//

import Foundation

protocol IntroViewDelegate {
    func nextButtonPressed()
}

class IntroView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    var delegate: IntroViewDelegate?
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        delegate?.nextButtonPressed()
    }
    
}
