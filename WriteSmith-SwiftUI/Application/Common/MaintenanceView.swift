//
//  MaintenanceView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/29/23.
//

import SwiftUI

struct MaintenanceView: View {
    
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                
                VStack {
                    Spacer()
                    
                    Text("Under Maintenance")
                        .font(.custom(Constants.FontName.body, size: 28.0))
                    
                    Text(Image(systemName: "exclamationmark.triangle.fill"))
                        .font(.custom(Constants.FontName.body, size: 28.0))
                    
                    Text("Please check back later...")
                        .font(.custom(Constants.FontName.bodyOblique, size: 17.0))
                        .opacity(0.6)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .background(Colors.background)
    }
    
}

#Preview {
    MaintenanceView()
}
