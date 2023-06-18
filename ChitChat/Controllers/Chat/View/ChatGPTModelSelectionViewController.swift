//
//  ChatGPTModelSelectionViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/10/23.
//

import Foundation

protocol ChatGPTModelSelectionViewControllerDelegate {
    func didSetGPTModel(model: GPTModels)
}

class ChatGPTModelSelectionViewController: UIViewController {
    
    // Constants
    let premiumPromotionPopupTitle = "Free Trial Unlocked!"
    let premiumPromotionPopupText = "\nUnlock GPT-4 FREE for 3 days. Upgrade your essays and be part of the AI revolution."
    
    let backgroundAnimationDuration = 0.1
    let popupAnimationDuration = 0.2
    
    // Instance variables
    var backgroundView: UIVisualEffectView?
    
    var defaultBackgroundOpacity: CGFloat = 1.0
    var originalPopupFrame: CGRect?
    var hasMovedToShow: Bool = false
    
    // Delegate
    var delegate: ChatGPTModelSelectionViewControllerDelegate?
    
    
    lazy var rootView: ChatGPTModelSelectionView = {
        let view = RegistryHelper.instantiateAsView(nibName: Registry.Chat.View.chatGPTModelSelection, owner: self) as! ChatGPTModelSelectionView
        view.delegate = self
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the active one to have a checkmark
        switch (GPTModelHelper.getCurrentChatModel()) {
        case .gpt3turbo:
            rootView.freeModelButton.hasCheckmark = true
            rootView.paidModelButton.hasCheckmark = false
            break
        case .gpt4:
            rootView.freeModelButton.hasCheckmark = false
            rootView.paidModelButton.hasCheckmark = true
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasMovedToShow {
            // Set the backgroundView opacity
            backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            backgroundView!.frame = rootView.frame
//            backgroundView!.backgroundColor = .black
            backgroundView!.alpha = 0.0
            rootView.insertSubview(backgroundView!, at: 0)
            
            // Add gesture recognizer to backgroundView
            let tapBackgroundGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressCloseButton))
            backgroundView?.addGestureRecognizer(tapBackgroundGestureRecognizer)
            
            // Set the position of the popup view
            originalPopupFrame = rootView.popupView.frame
            let movedDownFrame = CGRect(x: rootView.popupView.frame.minX, y: rootView.popupView.frame.minY + rootView.popupView.frame.height, width: rootView.popupView.frame.width, height: rootView.popupView.frame.height)
            rootView.popupView.frame = movedDownFrame
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animate backgroundView opacity
        UIView.animate(withDuration: backgroundAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, animations: {
            self.backgroundView!.alpha = self.defaultBackgroundOpacity
        })
//        UIView.animate(withDuration: backgroundAnimationDuration, delay: 0.0, options: .curveEaseOut, animations: {
//            self.backgroundView!.alpha = self.defaultBackgroundOpacity
//        })
        
        // Animate popup view moving up
        UIView.animate(withDuration: popupAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, animations: {
            self.rootView.popupView.frame = self.originalPopupFrame!
        })
//        UIView.animate(withDuration: popupAnimationDuration, delay: 0.0, options: .curveEaseOut, animations: {
//            self.rootView.popupView.frame = self.originalPopupFrame!
//        })
        
        hasMovedToShow = true
        
    }
    
    func moveAndDismiss() {
        // Use the longer animation duration so that the background doesn't dismiss first
        let longerAnimationDuration = max(backgroundAnimationDuration, popupAnimationDuration)
        
        // Animate backgroundView opacity
//        UIView.animate(withDuration: backgroundAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, animations: {
//            self.backgroundView!.alpha = 0.0
//        })
        UIView.animate(withDuration: longerAnimationDuration, delay: 0.0, options: .curveEaseIn, animations: {
            self.backgroundView!.alpha = 0.0
        })
        
        // Animate popup view moving down
//        UIView.animate(withDuration: popupAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, animations: {
//            let movedDownFrame = CGRect(x: self.rootView.popupView.frame.minX, y: self.rootView.popupView.frame.minY + self.rootView.popupView.frame.height, width: self.rootView.popupView.frame.width, height: self.rootView.popupView.frame.height)
//            self.rootView.popupView.frame = movedDownFrame
//        })
        UIView.animate(withDuration: longerAnimationDuration, delay: 0.0, options: .curveEaseIn, animations: {
            let movedDownFrame = CGRect(x: self.rootView.popupView.frame.minX, y: self.rootView.popupView.frame.minY + self.rootView.popupView.frame.height, width: self.rootView.popupView.frame.width, height: self.rootView.popupView.frame.height)
            self.rootView.popupView.frame = movedDownFrame
        })
        
        // Dismiss after the longer delay
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + longerAnimationDuration, execute: {
            self.dismiss(animated: false)
        })
    }
    
    func showPremiumPromotionPopup() {
        let ac = UIAlertController(title: premiumPromotionPopupTitle, message: premiumPromotionPopupText, preferredStyle: .alert)
        ac.view.tintColor = Colors.alertTintColor
        ac.addAction(UIAlertAction(title: "Try Free", style: .default, handler: { alertAction in
            UltraViewControllerPresenter.presentOnTop(animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Pass", style: .cancel))
        present(ac, animated: true)
    }
    
}
