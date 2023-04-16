//
//  CameraViewController+CameraViewDelegate.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/15/23.
//

import AVKit
import Foundation
import Vision

extension CameraViewController: CameraViewDelegate {
    
    func cameraButtonPressed() {
        if rootView.cameraButton.backgroundImage(for: .normal) == UIImage(named: Constants.ImageName.cameraButtonNotPressed) || rootView.cameraButton.backgroundImage(for: .normal) == UIImage(named: Constants.ImageName.cameraButtonPressed) {
            // Camera was enabled, so take the photo
            guard let capturePhotoOutput = self.capturePhotoOutput else { return }
            
            // Set photoSettings
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.flashMode = .auto
            
            // Capture the photo
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        } else {
            // Camera was not enabled, so delete the picture and redo
            startUpCameraAgain()
            deInitializeCropView()
            
            // Show Tap to Scan button
            UIView.animate(withDuration: 0.2, animations: {
                self.rootView.tapToScanImageView.alpha = 1.0
            })
        }
    }
    
    func cancelButtonPressed() {
        dismiss(animated: true)
    }
    
    func imageButtonPressed() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true)
        }
    }
    
    func scanButtonPressed() {
        // Get the output image
        let scale = max((previewImageView.image?.size.width)! / rootView.container.frame.width, (previewImageView.image?.size.height)! / rootView.container.frame.height)
        
        guard let outputImage = previewImageView.image?.cgImage?.cropping(to: CGRect(x: rootView.cropViewLeadingConstraint.constant * scale, y: rootView.cropViewTopConstraint.constant * scale, width: (rootView.container.frame.width - rootView.cropViewLeadingConstraint.constant - rootView.cropViewTrailingConstraint.constant) * scale, height: (rootView.container.frame.height - rootView.cropViewTopConstraint.constant - rootView.cropViewBottomConstraint.constant) * scale)) else {
            print("Could not get the cropped image.")
            startUpCameraAgain()
            return
        }
        
        // For testing
//        previewImageView.contentMode = .scaleAspectFit
//        previewImageView.image = UIImage(cgImage: outputImage)
        
        // Do text recognition
        let requestHandler = VNImageRequestHandler(cgImage: outputImage)
        let request = VNRecognizeTextRequest(completionHandler: { request, error in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }
            
            // Process the recognized strings.
            //TODO: - Send prompt to server with prefix, "answer this question in detail" or something, or maybe just send it for now
            var combinedStrings = ""
            for recognizedString in recognizedStrings {
                combinedStrings = "\(combinedStrings) \(recognizedString)"
            }
            
            // If there was no text found, present an alertcontroller and allow the user to try cropping again
            if combinedStrings == "" {
                let ac = UIAlertController(title: "No Text Found", message: "Could not find text in the selection. Please try again.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Done", style: .cancel))
                self.present(ac, animated: true)
                return
            }
            
            let trimmedString = combinedStrings.trimmingCharacters(in: .whitespaces)
            
            if self.delegate != nil {
                self.delegate.didGetScan(text: trimmedString)
                self.dismiss(animated: true)
            }
        })
        
        request.recognitionLevel = .accurate
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
}
