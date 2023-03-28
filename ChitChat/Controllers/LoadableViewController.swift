//
//  LoadableViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/24/23.
//

import Foundation

protocol LoadableViewController: UIViewController {
    associatedtype O
    
    var rootView: O! { get set }
    
    func set(rootView: O) -> Self
}
