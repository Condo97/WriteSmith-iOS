//
//  GPTModelHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/9/23.
//

import Foundation

class GPTModelHelper {
    
    @discardableResult
    static func setDefaultChatModel() -> GPTModels {
        return setCurrentChatModel(model: GPTModelTierSpecification.defaultModel)
    }
    
    static func getCurrentChatModel() -> GPTModels {
        // Set the default chat model if there is no model set
        if UserDefaults.standard.string(forKey: Constants.userDefaultStoredChatGPTModel) == nil || GPTModels(rawValue: UserDefaults.standard.string(forKey: Constants.userDefaultStoredChatGPTModel)!) == nil {
            return setDefaultChatModel()
        }
        
        // Get the model and check for premium before returning
        let model = GPTModels(rawValue: UserDefaults.standard.string(forKey: Constants.userDefaultStoredChatGPTModel)!)!
        
        //TODO: Should this be here?
        if !PremiumHelper.get() {
            if !GPTModelTierSpecification.freeModels.contains(where: {$0 == model}) {
                return setDefaultChatModel()
            }
        }
        
        return model
    }
    
    @discardableResult
    static func setCurrentChatModel(model: GPTModels) -> GPTModels {
        UserDefaults.standard.set(model.rawValue, forKey: Constants.userDefaultStoredChatGPTModel)
        
        return model
    }
    
}
