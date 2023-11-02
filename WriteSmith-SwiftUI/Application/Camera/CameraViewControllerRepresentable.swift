//
//  CameraViewControllerRepresentable.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/28/23.
//

import SwiftUI

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    
    var onScan: (String)->Void
    
    class CameraViewControllerCoordinator: CameraViewControllerDelegate {
        
        var onScan: (String)->Void
        
        init(onScan: @escaping (String)->Void) {
            self.onScan = onScan
        }
        
        func didGetScan(text: String) {
            onScan(text)
        }
        
    }
    
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        
        cameraViewController.delegate = context.coordinator
        
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> CameraViewControllerCoordinator {
        CameraViewControllerCoordinator(onScan: onScan)
    }
    
}

#Preview {
    CameraViewControllerRepresentable(onScan: { scanText in
        
    })
    .ignoresSafeArea()
}
