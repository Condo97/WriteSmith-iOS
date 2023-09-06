//
//  EssayViewController+EntryEssayTableViewCellDelegat.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

extension EssayViewController: EssayEntryTableViewCellDelegate {
    
    func didPressSubmitButton(sender: Any) {
        // Do haptic
        HapticHelper.doMediumHaptic()
        
        // If not premium and there are more essays than cap give the user an upgrade prompt
        if !PremiumHelper.get() {
            // TODO: Is this a good way to do this?
            if let fetchedResultsTableViewDataSource = fetchedResultsTableViewDataSource, fetchedResultsTableViewDataSource.countFetchedObjects() >= UserDefaults.standard.integer(forKey: Constants.userDefaultStoredFreeEssayCap) {
//            if self.essays.count >= UserDefaults.standard.integer(forKey: Constants.userDefaultStoredFreeEssayCap) {
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
        
        // Get and unwrap entry cell, otherwise return
        guard let entryCell = fetchedResultsTableViewDataSource?.getTopViewCell() as? EssayEntryTableViewCell else {
            // TODO: Handle errors
            return
        }
        
        // Get inputText
        let inputText: String! = entryCell.textView.text
        
        // Call textViewOnSubmit
        entryCell.textViewOnSubmit(useTryPlaceholder: !PremiumHelper.get())
        
        // Update entry size
        updateInputTextViewSize(textView: entryCell.textView)
        
//        // Insert loading section at top of essaySection
//        if !isProcessingChat {
//            isProcessingChat = true
//
//            DispatchQueue.main.async {
//                self.sourcedTableViewManager.sources[self.essaySection].insert(LoadingEssayTableViewCellSource(), at: 0)
//
//                self.rootView.tableView.reloadData()
//            }
//        }
        
        // Show loading cell
        self.fetchedResultsTableViewDataSource?.showLoadingCell()
        
//        #warning("DON'T FORGET TO DO THIS!")
//        let usePaidModel = GPTModelHelper.getCurrentChatModel() == .paid
        let currentModel = GPTModelHelper.getCurrentChatModel()
        
        ChatRequestHelper.get(inputText: inputText, conversationID: nil, model: currentModel, completion: {responseText, finishReason, conversationID, remaining in
            // Call textViewOnFinishedGenerating
            entryCell.textViewOnFinishedGenerating()
            
            //TODO: Do something with conversationID
            DispatchQueue.main.async {
//                // Delete loading section if isProcessingChat
//                if self.isProcessingChat {
//                    self.isProcessingChat = false
//
//                    self.sourcedTableViewManager.sources[self.essaySection].remove(at: 0)
//
//                    self.rootView.tableView.reloadData()
//                }
                
                // Hide loading cell
                UIView.performWithoutAnimation {
                    self.fetchedResultsTableViewDataSource?.hideLoadingCell()
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
    
    func textViewDidChange(_ textView: UITextView) {
        // Get the entry cell
        if let entryCell = rootView.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? EssayEntryTableViewCell {
            // Is it the input text field?
            if textView == entryCell.textView {
                entryCell.textViewCurrentlyWriting()
                updateInputTextViewSize(textView: textView)
            }
        }
    }
    
    private func updateInputTextViewSize(textView: UITextView) {
        if textView == (rootView.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            DispatchQueue.main.async {
                let size = CGSize(width: textView.frame.size.width, height: .infinity)
                let estimatedSize = textView.sizeThatFits(size)
                
                textView.constraints.forEach{ (constraint) in
                    if constraint.firstAttribute == .height {
                        self.rootView.tableView.beginUpdates()
                        constraint.constant = estimatedSize.height
                        self.rootView.tableView.endUpdates()
                    }
                }
            }
            
            guard textView.contentSize.height < 70.0 else { textView.isScrollEnabled = true; return }
            
            textView.isScrollEnabled = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == (rootView.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! EssayEntryTableViewCell).textView {
            if text == "\n" {
                view.endEditing(true)
                return false
            }
            
            return true
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let entryCell = rootView.tableView.cellForRow(at: IndexPath(row: 0, section: entrySection)) as? EssayEntryTableViewCell {
            if textView == entryCell.textView {
                entryCell.textViewStartWriting()
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let entryCell = rootView.tableView.cellForRow(at: IndexPath(row: 0, section: entrySection)) as? EssayEntryTableViewCell {
            if textView == entryCell.textView {
                entryCell.textViewFinishedWriting(useTryPlaceholder: !PremiumHelper.get())
            }
        }
    }
    
}
