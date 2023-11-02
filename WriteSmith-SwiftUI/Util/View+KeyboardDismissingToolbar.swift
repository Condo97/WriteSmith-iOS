//
//  View+KeyboardDismissingToolbar.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation
import SwiftUI

extension View {
    
    func keyboardDismissingTextFieldToolbar(_ dismissButtonText: String, color: Color) -> some View {
        self
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button(action: {
                        KeyboardDismisser.dismiss()
                    }) {
                        Text(dismissButtonText)
                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                            .foregroundStyle(color)
                    }
                }
            }
    }
    
    func keyboardSavingTextFieldToolbar(saveText: String, cancelText: String, color: Color, save: @escaping ()->Void, cancel: (()->Void)? = nil) -> some View {
        self
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button(action: {
                        cancel?()
                        
                        KeyboardDismisser.dismiss()
                    }) {
                        Text(cancelText)
                            .font(.custom(Constants.FontName.body, size: 17.0))
                            .foregroundStyle(color)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        save()
                        
                        KeyboardDismisser.dismiss()
                    }) {
                        Text(saveText)
                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                            .foregroundStyle(color)
                    }
                }
            }
    }
    
}
