//
//  ChatViewController+CameraViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/19/23.
//

import Foundation

extension ChatViewController: CameraViewControllerDelegate {
    
    func didGetScan(text: String) {
        Task {
            do {
                try await generateChat(inputText: text)
            } catch {
                // TODO: Handle error
                print("Error generating chat in didGetScan in ChatViewController CameraViewControllerDelegate... \(error)")
            }
        }
    }
    
}

