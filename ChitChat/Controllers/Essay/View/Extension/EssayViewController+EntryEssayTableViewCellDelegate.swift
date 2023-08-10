//
//  EssayViewController+EntryEssayTableViewCellDelegat.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

extension EssayViewController: EntryEssayTableViewCellDelegate {
    
    func didPressSubmitButton(sender: Any) {
        // Do haptic
        HapticHelper.doMediumHaptic()
        
        // If not premium and there are more essays than cap give the user an upgrade prompt
        if !PremiumHelper.get() {
            if self.essays.count >= UserDefaults.standard.integer(forKey: Constants.userDefaultStoredFreeEssayCap) {
                let ac = UIAlertController(title: "Upgrade", message: "You've reached the limit for free essays. Please upgrade to get unlimited full-length essays.\n\n(3-Day Free Trial)", preferredStyle: .alert)
                ac.view.tintColor = Colors.alertTintColor
                ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
                    self.goToUltraPurchase()
                }))
                ac.addAction(UIAlertAction(title: "Close", style: .cancel))
                
                DispatchQueue.main.async {
                    self.present(ac, animated: true)
                }
                
                return
            }
        }
        
        guard let cell = rootView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EssayEntryTableViewCell else {
            print("Entry cell not visible! Not generating chat...")
            return
        }
        
        guard let inputText = cell.textView.text else {
            return
        }
        
        // Call textViewOnSubmit
        cell.textViewOnSubmit(useTryPlaceholder: !PremiumHelper.get())
        
        // Update entry size
        updateInputTextViewSize(textView: cell.textView)
        
        // Insert loading section at top of essaySection
        if !isProcessingChat {
            isProcessingChat = true
            
            DispatchQueue.main.async {
                self.sourcedTableViewManager.sources[self.essaySection].insert(LoadingEssayTableViewCellSource(), at: 0)
                
                self.rootView.tableView.reloadData()
            }
        }
        
//        #warning("DON'T FORGET TO DO THIS!")
//        let usePaidModel = GPTModelHelper.getCurrentChatModel() == .paid
        let currentModel = GPTModelHelper.getCurrentChatModel()
        
        ChatRequestHelper.get(inputText: inputText, conversationID: nil, model: currentModel, completion: {responseText, finishReason, conversationID, remaining in
            // Call textViewOnFinishedGenerating
            cell.textViewOnFinishedGenerating()
            
            //TODO: Do something with conversationID
            DispatchQueue.main.async {
                // Delete loading section if isProcessingChat
                if self.isProcessingChat {
                    self.isProcessingChat = false
                    
                    self.sourcedTableViewManager.sources[self.essaySection].remove(at: 0)
                    
                    self.rootView.tableView.reloadData()
                }
                
                // Trim first occurence of \n\n if it exists
                var trimmedResponseText = responseText
                if let firstOccurence = responseText.range(of: "\n\n") {
                    trimmedResponseText.removeSubrange(responseText.startIndex..<firstOccurence.upperBound)
                }
                
                // If finish reason is length and user is not premium append the length finish reason additional text
                if finishReason == FinishReasons.length && !PremiumHelper.get() {
                    trimmedResponseText += Constants.lengthFinishReasonAdditionalText
                }
                
                // Set firstChat to false
                self.firstChat = false
                
                // Add essay
                Task {
                    do {
                        try await self.addEssay(prompt: inputText, essayText: trimmedResponseText)
                    } catch {
                        // TODO: Handle error
                        print("Could not add essay in EssayViewController EssayEntryTableViewCellDelegate didPressSubmitButton... \(error)")
                    }
                }
                
                // If user is not premium, and finish reason is limit, show a limit reached alert
                //            if !PremiumHelper.get() {
                //                let ac = UIAlertController(title: "Limit Reached", message: "You've reached your daily chat limit. Upgrade for unlimited chats...", preferredStyle: .alert)
                //                ac.addAction(UIAlertAction(title: "Close", style: .cancel))
                //                ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
                //                    self.goToUltraPurchase()
                //                }))
                //                self.present(ac, animated: true)
                //            }
            }
        })
    }
    
}
