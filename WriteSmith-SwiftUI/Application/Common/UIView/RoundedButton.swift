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
//                buttonArrowImageView.image = UIImage.gifImageWithName("arrowGif")
                buttonArrowImageView.image = UIImage(systemName: "arrow.forward")
                buttonArrowImageView.tintColor = titleColor(for: state)
                buttonArrowImageView.alpha = 1.0
                
                addSubview(buttonArrowImageView)
            }
        }
    }
    
    @IBInspectable open var hasActivityView: Bool = false {
        didSet {
            if hasActivityView {
                activityView = UIActivityIndicatorView()
                activityView.style = .medium
                activityView.color = tintColor
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
    @IBInspectable open var borderWidth: CGFloat = UIConstants.borderWidth
    @IBInspectable open var borderColor: UIColor = UIColor(Colors.elementBackgroundColor)

    @IBInspectable open var color: UIColor = UIColor(Colors.elementBackgroundColor) {
        didSet {
            buttonArrowImageView.tintColor = color
            activityView.color = color
            tintColor = color
        }
    }
    
    var buttonArrowImageView = UIImageView()
    var activityView = UIActivityIndicatorView()
    var checkmark = UIImageView()
    
    /* For arrow and activity view */
    let activityAccessoryWidth = 24.0
    let activityAccessoryHeight = 24.0
    
    let arrowAccessoryWidth = 30.0
    let arrowAccessoryHeight = 24.0
    
    let accessoryInset = 24.0
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        tintColor = color
        
        self.layer.cornerRadius = UIConstants.cornerRadius
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
            let font = UIFont(name: Constants.FontName.black, size: 25.0)
            self.setAttributedTitle(NSAttributedString(string: self.titleLabel?.text ?? "", attributes: [.font: font!]), for: .normal)
        }
        
        if hasActivityView {
            activityView.frame = CGRect(x: frame.size.width - (activityAccessoryWidth / 2) - accessoryInset, y: (frame.size.height - activityAccessoryHeight) / 2, width: activityAccessoryWidth, height: activityAccessoryHeight)
        }
        
        if hasArrow {
            buttonArrowImageView.frame = CGRect(x: frame.size.width - (arrowAccessoryWidth / 2) - accessoryInset, y: (frame.size.height - arrowAccessoryHeight) / 2, width: arrowAccessoryWidth, height: arrowAccessoryHeight)
            
            buttonArrowImageView.tintColor = titleColor(for: state)
        }
        
        if hasCheckmark {
            let height = frame.size.height - 24
            checkmark.frame = CGRect(x: 24 / 2, y: 24 / 2, width: height, height: height)
        }
            
        self.addTarget(self, action: #selector(self.bounce(sender:)), for: .touchDown)
        self.addTarget(self, action: #selector(self.bounce(sender:)), for: .touchDragInside)
        self.addTarget(self, action: #selector(self.bounceRelease(sender:)), for: .touchCancel)
        self.addTarget(self, action: #selector(self.bounceRelease(sender:)), for: .touchDragOutside)
        self.addTarget(self, action: #selector(self.bounceRelease(sender:)), for: .touchUpInside)
    }
    
    @objc private func bounce(sender: UIButton) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Animate button bounce
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { (_) in
            
        }
    }
    
    @objc private func bounceRelease(sender: UIButton) {
        // Animate button unbounce
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    func startAnimatingActivityView() {
        // Check if there is an arrow and if so hide it until stopAnimatingActivityView is called
        DispatchQueue.main.async {
            if self.hasArrow {
                UIView.animate(withDuration: 0.4, animations: {
                    self.buttonArrowImageView.alpha = 0.0
                }, completion: { boolean in
                    UIView.animate(withDuration: 0.4, animations: {
                        self.activityView.startAnimating()
                    })
                })
            } else {
                self.activityView.startAnimating()
            }
        }
        
    }
    
    func stopAnimatingActivityView() {
        // Check if there is an arrow and if so unhide it
        DispatchQueue.main.async {
            if self.hasArrow {
                UIView.animate(withDuration: 0.4, animations: {
                    self.activityView.stopAnimating()
                }, completion: { boolean in
                    UIView.animate(withDuration: 0.4, animations: {
                        self.buttonArrowImageView.alpha = 1.0
                    })
                })
            } else {
                self.activityView.stopAnimating()
            }
        }
    }
}

