//
//  FullScreenCoverBackgroundCleanerView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/25/23.
//

import Foundation
import SwiftUI

struct FullScreenCoverBackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
