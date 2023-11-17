//
//  CameraViewControllerRepresentable.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/28/23.
//

import SwiftUI

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    
    @Binding var isShowing: Bool
    var withCropFrame: CGRect?
    var withImage: UIImage?
    var onAttach: (_ image: UIImage, _ cropFrame: CGRect?, _ unmodifiedImage: UIImage?)->Void
    var onScan: (String)->Void
    
    class CameraViewControllerCoordinator: CameraViewControllerDelegate {
        
        @Binding var isShowing: Bool
        var onAttach: (_ image: UIImage, _ cropFrame: CGRect?, _ unmodifiedImage: UIImage?)->Void
        var onScan: (String)->Void
        
        init(isShowing: Binding<Bool>, onAttach: @escaping (_ image: UIImage, _ cropFrame: CGRect?, _ unmodifiedImage: UIImage?)->Void, onScan: @escaping (String)->Void) {
            self._isShowing = isShowing
            self.onAttach = onAttach
            self.onScan = onScan
        }
        
        func didAttachImage(image: UIImage, cropFrame: CGRect?, unmodifiedImage: UIImage?) {
            onAttach(image, cropFrame, unmodifiedImage)
        }
        
        func didGetScan(text: String) {
            onScan(text)
        }
        
        func dismiss() {
            isShowing = false
        }
        
    }
    
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        
        cameraViewController.delegate = context.coordinator
        
        if let withImage = withImage {
            cameraViewController.initializeCropView(with: withImage, cropFrame: withCropFrame, fromCamera: false, contentMode: .scaleAspectFit)
            
            // I'm doing this here to avoid the logic in the cameraViewController itself lol
            cameraViewController.rootView.showCropViewSwitch.isOn = withCropFrame != nil
            cameraViewController.rootView.showCropViewSwitchChanged(cameraViewController.rootView.showCropViewSwitch)
        }
        
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> CameraViewControllerCoordinator {
        CameraViewControllerCoordinator(isShowing: $isShowing, onAttach: onAttach, onScan: onScan)
    }
    
}

#Preview {
    CameraViewControllerRepresentable(
        isShowing: .constant(true),
        onAttach: { image, cropRect, unmodifiedImage in
            
        },
        onScan: { scanText in
            
        })
    .ignoresSafeArea()
}
