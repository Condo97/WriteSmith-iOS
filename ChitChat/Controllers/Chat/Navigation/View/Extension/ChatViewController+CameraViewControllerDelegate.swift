//
//  ChatViewController+CameraViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/19/23.
//

import Foundation

extension ChatViewController: CameraViewControllerDelegate {
    func didGetScan(text: String) {
        generateChat(inputText: text)
    }
}

