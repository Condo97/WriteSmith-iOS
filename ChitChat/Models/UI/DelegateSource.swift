//
//  DelegateSource.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/25/23.
//

import Foundation

protocol DelegateSource<T> {
    associatedtype T
    
    var delegate: T? { get set }
    
}
