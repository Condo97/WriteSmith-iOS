//
//  ToolbarController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/25/23.
//

import Foundation

protocol DoneToolbarControllerDelegate {
    func doneToolbarButtonPressed(_ sender: Any)
}

class DoneToolbarController: Any {
    
    // Constants
    let TOOLBAR_HEIGHT = 48.0
    
    // Instance variables
    var toolbar: UIToolbar
    
    // Initialization variables
    var delegate: DoneToolbarControllerDelegate?
    
    
    init() {
        // Setup Keyboard Toolbar
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: TOOLBAR_HEIGHT))
        toolbar.barStyle = .default
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneToolbarButtonPressed))]
        toolbar.tintColor = Colors.elementTextColor
        toolbar.barTintColor = Colors.elementBackgroundColor
        toolbar.sizeToFit()
    }
    
    @objc func doneToolbarButtonPressed(_ sender: Any) {
        delegate?.doneToolbarButtonPressed(sender)
    }
    
}
