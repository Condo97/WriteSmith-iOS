//
//  LoadingState.swift
//  ChitChat
//
//  Created 4/16/23.
// https://swiftbysundell.com/articles/handling-loading-states-in-swiftui/
// This is for IAP handling
//

import Foundation

enum LoadingState<Value> {
    case idle
    case loading
    case failed(Error)
    case loaded(Value)
}
