//
//  ChatViewController+ChatGPTModelViewControllerDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/10/23.
//

import Foundation

extension ChatViewController: ChatGPTModelSelectionViewControllerDelegate {
    
    func didSetGPTModel(model: GPTModels) {
        GPTModelHelper.setCurrentChatModel(model: model)
        setGPTViewElements()
    }
    
}
