//
//  RoundedButton.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit

class RoundedButton: UIButton {
    @IBInspectable open var hasArrow: Bool = false {
        didSet {
            if hasArrow {
                buttonArrowImageView = UIImageView()
                buttonArrowImageView.image = UIImage(systemName: "arrow.right")
                addSubview(buttonArrowImageView)
            }
        }
    }
    
    @IBInspectable open var hasActivityView: Bool = false {
        didSet {
            if hasActivityView {
                activityView = UIActivityIndicatorView(frame: CGRect(x: frame.size.width - accessoryWidth - accessoryInset, y: (frame.size.height - accessoryHeight) / 2, width: accessoryWidth, height: accessoryHeight))
                activityView.hidesWhenStopped = true
                activityView.stopAnimating()
                addSubview(activityView)
            }
        }
    }
    
    @IBInspectable open var hasCheckmark: Bool = false {
        didSet {
            if hasCheckmark {
                checkmark = UIImageView()
                checkmark.image = UIImage(systemName: "checkmark.circle")
                                
                addSubview(checkmark)
            }
        }
    }
    
    @IBInspectable open var filled: Bool = false
    @IBInspectable open var bigFont: Bool = false
    @IBInspectable open var borderWidth: CGFloat = Constants.borderWidth
    @IBInspectable open var borderColor: UIColor = Colors.accentColor
    
    var buttonArrowImageView = UIImageView()
    var activityView = UIActivityIndicatorView()
    var checkmark = UIImageView()
    
    /* For arrow and activity view */
    let accessoryWidth = 40.0
    let accessoryHeight = 35.0
    let accessoryInset = 14.0
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = Constants.cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        
        self.titleLabel?.numberOfLines = 1
//        if filled {
//            //TODO: - Make sure that the bottom button is separate from filled, maybe add a new IBInspectable?
//
//            self.tintColor = UIConstants.background
//            self.layer.borderColor = UIConstants.border.cgColor
//            self.layer.backgroundColor = UIConstants.border.cgColor
//            self.setTitleColor(UIConstants.textColor, for: .disabled)
//            self.setTitleColor(UIConstants.background, for: .normal)
//        } else {
//            self.tintColor = UIConstants.textColor
//            self.layer.borderColor = UIConstants.border.cgColor
//            self.setTitleColor(UIConstants.background, for: .normal)
//            self.setTitleColor(UIConstants.background, for: .selected)
//        }
        
        if bigFont {
            let font = UIFont(name: Constants.primaryFontNameBold, size: 25.0)
            self.setAttributedTitle(NSAttributedString(string: self.titleLabel?.text ?? "", attributes: [.font: font!]), for: .normal)
        }
        
        if hasArrow {
            buttonArrowImageView.frame = CGRect(x: frame.size.width - accessoryWidth - accessoryInset, y: (frame.size.height - accessoryHeight) / 2, width: accessoryWidth, height: accessoryHeight)
        }
        
        if hasCheckmark {
            let height = frame.size.height - 24
            checkmark.frame = CGRect(x: 24 / 2, y: 24 / 2, width: height, height: height)
        }
            
        self.addTarget(self, action: #selector(self.bounce(sender:)), for: .touchDown)
        self.addTarget(self, action: #selector(self.bounceRelease(sender:)), for: .touchUpInside)
    }
    
    @objc private func bounce(sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { (_) in
            
        }
    }
    
    @objc private func bounceRelease(sender: UIButton) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
}
