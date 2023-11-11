//
//  GPTModelHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/9/23.
//

import Foundation

class GPTModelHelper {
    
    private static let defaultModel = GPTModelTierSpecification.defaultModel
    
    static var currentChatModel: GPTModels {
        get {
            // Set the default chat model if there is no model set
            if UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredChatGPTModel) == nil || GPTModels(rawValue: UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredChatGPTModel)!) == nil {
                return defaultModel
            }
            
            // Get the model and check for premium before returning
            let model = GPTModels(rawValue: UserDefaults.standard.string(forKey: Constants.UserDefaults.userDefaultStoredChatGPTModel)!)!
            
            //TODO: Should this be here? - Comented this out, this check should probably be done when setting it, but now I'm uncommenting it becuase I'm realizing it's in the "Get," the logic should be implemented anyways, and this just operates as a check
            if !PremiumUpdater.get() {
                if !GPTModelTierSpecification.freeModels.contains(where: {$0 == model}) {
                    return defaultModel
                }
            }
            
            return model
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Constants.UserDefaults.userDefaultStoredChatGPTModel)
        }
        
    }
    
//    @discardableResult
//    static func setDefaultChatModel() -> GPTModels {
//        return setCurrentChatModel(model: GPTModelTierSpecification.defaultModel)
//    }
//    
//    static func getCurrentChatModel() -> GPTModels {
//        // Set the default chat model if there is no model set
//        if UserDefaults.standard.string(forKey: Constants.userDefaultStoredChatGPTModel) == nil || GPTModels(rawValue: UserDefaults.standard.string(forKey: Constants.userDefaultStoredChatGPTModel)!) == nil {
//            return setDefaultChatModel()
//        }
//        
//        // Get the model and check for premium before returning
//        let model = GPTModels(rawValue: UserDefaults.standard.string(forKey: Constants.userDefaultStoredChatGPTModel)!)!
//        
//        //TODO: Should this be here?
//        if !PremiumHelper.get() {
//            if !GPTModelTierSpecification.freeModels.contains(where: {$0 == model}) {
//                return setDefaultChatModel()
//            }
//        }
//        
//        return model
//    }
//    
//    @discardableResult
//    static func setCurrentChatModel(model: GPTModels) -> GPTModels {
//        UserDefaults.standard.set(model.rawValue, forKey: Constants.userDefaultStoredChatGPTModel)
//        
//        return model
//    }
    
}
