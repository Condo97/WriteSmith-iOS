//
//  ChatViewController+HTTPSHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/19/23.
//

import Foundation

extension ChatViewController: HTTPSHelperDelegate {
    func didRegisterUser(json: [String : Any]?) {
        guard let body = json?["Body"] as? [String: Any] else {
            print("Error! No Body in response...\n\(String(describing: json))")
            return
        }
        
        guard let authToken = body["authToken"] as? String else {
            print("Error! No AuthToken in response...\n\(String(describing: json))")
            return
        }
        
        var shouldCheckForPremium = false
        if UserDefaults.standard.string(forKey: Constants.authTokenKey) == nil {
            shouldCheckForPremium = true
        }
        
        HTTPSHelper.getRemaining(delegate: self, authToken: authToken)
        UserDefaults.standard.set(authToken, forKey: Constants.authTokenKey)
        
        if shouldCheckForPremium {
            doServerPremiumCheck()
        }
    }
    
    func getRemaining(json: [String : Any]?) {
        guard let body = json?["Body"] as? [String: Any] else {
            print("Error! No Body in response...\n\(String(describing: json))")
            return
        }
        
        guard let remaining = body["remaining"] as? Int else {
            print("Error! No remaining in response...\n\(String(describing: json))")
            return
        }
        
        self.remaining = remaining
        updateRemainingText()
    }
    
    func didGetAndSaveImportantConstants(json: [String : Any]?) {
        
    }
    
    func getChat(json: [String : Any]?) {
        if UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
            submitButton.isEnabled = true
            cameraButton.isEnabled = true
        }
        
        // Stop the processing animation (won't stop if already stopped)
        stopProcessingAnimation()
        
        guard let success = json?["Success"] as? Int else {
            print("Error! No success in response...\n\(String(describing: json))")
            return
        }
        
        if success == 1 {
            //Everything's good!
            guard let body = json?["Body"] as? [String: Any] else {
                print("Error! No Body in response...\n\(String(describing: json))")
                return
            }
            
            guard let output = body["output"] as? String else {
                print("Error! No Output in response...\n\(String(describing: json))")
                return
            }
            
            guard let remaining = body["remaining"] as? Int else {
                print("Error! No Remaining in response...\n\(String(describing: json))")
                return
            }
            
            guard let finishReason = body["finishReason"] as? String else {
                print("Error! No Finish Reason in response...\n\(String(describing: json))")
                return
            }
            
            print(finishReason)
            // Trim first two lines off of output
            var trimmedOutput = output
            if output.contains("\n\n") {
                let firstOccurence = output.range(of: "\n\n")!
                trimmedOutput.removeSubrange(output.startIndex..<firstOccurence.upperBound)
            }
            
            if finishReason == FinishReasons.length && !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) {
                trimmedOutput += "...\n\nThis answer is too long for your plan. Please upgrade to Ultra for unlimited length."
            }
            
            self.remaining = remaining
            firstChat = false
            updateRemainingText()
            addChat(message: trimmedOutput, userSent: .ai)
            
            // Show ad at certain frequency
            if !UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) && self.remaining % Constants.adFrequency == 0 && !self.firstChat {
                if self.interstitial != nil {
                    //Display ad
                    self.interstitial?.present(fromRootViewController: self) //{
                    //                                let reward = self.interstitial?.adReward
                    //                                if reward?.amount == 0 {
                    //                                    //TODO: - Handle early ad close
                    //                                }
                    //}
                } else {
                    loadGAD() // Load if insertional is nil I guess lol
                }
            } else {
                // Otherwise show review prompt at certain frequency
                if ChatStorageHelper.getAllChats().count % Constants.reviewFrequency == 0 && !firstChat {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        DispatchQueue.main.async {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }
                }
            }
        } else if success == 51 {
            //Too many chats generated
            guard let body = json?["Body"] as? [String: Any] else {
                print("Wait... a body is supposed to be sent here, hm")
                return
            }
            
            guard let output = body["output"] as? String else {
                print("Error! No output in body...\n\(String(describing: json))")
                return
            }
            
            let ac = UIAlertController(title: "Limit Reached", message: "You've reached your daily chat limit. Upgrade for unlimited chats...", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Close", style: .cancel))
            ac.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { action in
                self.goToUltraPurchase()
            }))
            present(ac, animated: true)
            
            addChat(message: output, userSent: .ai)
        } else {
            print("Error! Unhandled error number...\n\(String(describing: json))")
        }
    }
    
    func getChatError() {
        DispatchQueue.main.async {
            // Stop the processing animation (won't try to stop if already stopped)
            self.stopProcessingAnimation()
            
            self.addChat(message: "There was an issue getting your chat. Please try a different prompt.", userSent: .ai)
        }
    }
}


