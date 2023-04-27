//
//  ExploreItemViewController+ComponentItemTableViewCellSourceEditingDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/26/23.
//

import Foundation

extension ExploreItemViewController: ComponentItemTableViewCellSourceEditingDelegate {
    
    func finishedEditing(source: ComponentItemTableViewCellSource) {
        // Get index of source in requiredComponentSources
        let index = requiredComponentSources.firstIndex(where: { $0 === source })
        
        // If index is not nil and the value text is blank, then the source is implied as required and is blank, so it should be in the array, which it is, so proceed
        if index != nil && (source.value == nil || source.value!.count == 0) {
            
        }
        
        // If index is nil and the value text is not blank, then the source has text and should therefore not be in the requiredComponentSources, which it is not becuase the index is nil, so proceed
        else if index == nil && (source.value != nil && source.value!.count > 0) {
            
        }
        
        // If the index is nil and the value text is blank, check if required, and if so add to requiredComponentSources and proceed
        else if index == nil && (source.value == nil || source.value!.count == 0) {
            requiredComponentSources.append(source)
        }
        
        // If the index is not nil and the value text is not blank, remove from requiredComponentSources and proceed
        else if index != nil && (source.value != nil && source.value!.count > 0) {
            requiredComponentSources.remove(at: index!)
        }
        
        // Call autoSetButtonEnabled
        autoSetButtonEnabled()
    }
    
}
