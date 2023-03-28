//
//  ChatViewController+CameraViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/19/23.
//

import Foundation

extension ChatViewController: CameraViewControllerDelegate {
    func didGetScan(text: String) {
        guard let authToken = UserDefaults.standard.string(forKey: Constants.authTokenKey) else {
            HTTPSHelper.registerUser(delegate: self)
            return
        }
        
        //Button is disabled until response for premium
        //Button is enabled BUT shows a popup when pressed
        if UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            submitButton.isEnabled = false
            cameraButton.isEnabled = false
        } else {
            DispatchQueue.main.async {
                self.submitButton.alpha = 0.8
                self.cameraButton.alpha = 0.8
                self.submitSoftDisable = true
            }
        }
         
        HTTPSHelper.getChat(delegate: self, authToken: authToken, inputText: text)
        addChat(message: text, userSent: .user)
        
        if !isProcessingChat {
            isProcessingChat = true
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)], with: .automatic)
            tableView.endUpdates()
        }
        
        // Show Ad if Not Premium
        loadGAD()
    }
}

