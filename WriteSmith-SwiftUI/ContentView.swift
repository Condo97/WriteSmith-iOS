//
//  ContentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/20/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    
    var body: some View {
        ZStack {
            
        }
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView()
}
