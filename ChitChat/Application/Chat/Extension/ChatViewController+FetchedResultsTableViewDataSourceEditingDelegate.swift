//
//  ChatViewController+ChatTableViewDataSourceEditingDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/5/23.
//

//import CoreData
//import Foundation
//
//extension ChatViewController: FetchedResultsTableViewDataSourceEditingDelegate {
//
//    func commit(editingStyle: UITableViewCell.EditingStyle, managedObject: NSManagedObject) {
//        if editingStyle == .delete {
//            if let chat = managedObject as? Chat {
//                // Show prompt for user to confirm deletion
//                let ac = UIAlertController(
//                    title: "Delete Chat",
//                    message: "Are you sure you want to delete this chat?",
//                    preferredStyle: .alert)
//                ac.addAction(UIAlertAction(
//                    title: "Delete",
//                    style: .destructive,
//                    handler: {action in
//                        Task {
//                            do {
//                                // Unwrap authToken, otherwise return
//                                guard let authToken = AuthHelper.get() else {
//                                    print("Could not unwrap AuthToken in ChatViewController ChatTableViewCellSourceDelegate!")
//                                    return
//                                }
//
//                                // Create deleteChatRequest and delete Chat from server
//                                let deleteChatRequest = DeleteChatRequest(
//                                    authToken: authToken,
//                                    chatID: Int(chat.chatID))
//
//                                let deleteChatStatusResponse = try await HTTPSConnector.deleteChat(request: deleteChatRequest)
//
//                                // Delete chat in core data
//                                try await ChatCDHelper.deleteChat(chatObjectID: chat.objectID)
//
//                            } catch {
//                                // TODO: Handle error
//                                print("Could not delete chat in delete in ChatViewController ChatTableViewCellSourceDelegate... \(error)")
//                            }
//
//
//                        }
//                    }))
//                ac.addAction(UIAlertAction(
//                    title: "Cancel",
//                    style: .cancel))
//
//                DispatchQueue.main.async {
//                    self.present(ac, animated: true)
//                }
//            }
//        }
//    }
//
//}
