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
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Get flash mode TODO: Fix this, make it more dynamic so it doesn't have to get caputreDevice
        let flashMode: AVCaptureDevice.FlashMode = {
            if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
                return switch captureDevice.torchMode {
                case .auto: .auto
                case .off: .off
                case .on: .on
                @unknown default: .off
                }
            }
            
            return .off
        }()
        
        // Take photo or delete and redo, depending on button image
        if rootView.cameraButton.backgroundImage(for: .normal) == UIImage(named: Constants.ImageName.cameraButtonNotPressed) || rootView.cameraButton.backgroundImage(for: .normal) == UIImage(named: Constants.ImageName.cameraButtonPressed) {
            // Camera was enabled, so take the photo
            guard let capturePhotoOutput = self.capturePhotoOutput else { return }
            
            // Set photoSettings
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isAutoStillImageStabilizationEnabled = true
//            photoSettings.isHighResolutionPhotoEnabled = true
            
            photoSettings.flashMode = flashMode
            
            // Capture the photo
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        } else {
            // Camera was not enabled, so delete the picture and redo
            startUpCamera()
            deInitializeCropView()
            
            // Show Tap to Scan button
            UIView.animate(withDuration: 0.2, animations: {
                self.rootView.tapToScanImageView.alpha = 1.0
            })
        }
    }
    
    func cancelButtonPressed() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Dismiss view
        delegate.dismiss()
//        dismiss(animated: true)
    }
    
    func imageButtonPressed() {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Show image picker if source type is available
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true)
        }
    }
    
    func attachImageButtonPressed() {
//        // Ensure previewImageView can be unwrapped, otherwise return
//        guard let previewImageView = previewImageView else {
//            // TODO: Handle errors
//            return
//        }
        
        // Ensure previewImage can be unwrapped, otherwise return
        guard let previewImage = previewImageView.image else {
            // TODO: Handle errors
            return
        }
        
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // Get croppedImage and cropFrame, either cropped or not depending on crop switch
        if rootView.showCropViewSwitch.isOn {
            let (croppedImage, cropFrame): (CGImage?, CGRect?) = {
                // Get the bounds of the image view and the previewImage
                let imageViewSize = previewImageView.bounds.size
                let imageSize = previewImage.size
                
                // Calculate the scale factor and the offset
                let widthScale = imageSize.width / imageViewSize.width
                let heightScale = imageSize.height / imageViewSize.height
                let scaleFactor = max(widthScale, heightScale)
                
                let scaledImageWidth = imageSize.width / scaleFactor
                let scaledImageHeight = imageSize.height / scaleFactor
                
                let imageOffsetX = (imageViewSize.width - scaledImageWidth) / 2
                let imageOffsetY = (imageViewSize.height - scaledImageHeight) / 2
                
                let cropAreaWidth = rootView.container.frame.width - rootView.cropViewLeadingConstraint.constant - rootView.cropViewTrailingConstraint.constant
                let cropAreaHeight = rootView.container.frame.height - rootView.cropViewTopConstraint.constant - rootView.cropViewBottomConstraint.constant
                
                // Calculate the cropping rectangle
                let cropFrame = CGRect(
                    x: (rootView.cropViewLeadingConstraint.constant - imageOffsetX) * scaleFactor,
                    y: (rootView.cropViewTopConstraint.constant - imageOffsetY) * scaleFactor,
                    width: cropAreaWidth * scaleFactor,
                    height: cropAreaHeight * scaleFactor
                )
                
                return (previewImageView.image?.cgImage?.cropping(to: cropFrame), cropFrame)
                //            } else {
                //                // Simply return the image as cgImage
                //                return previewImageView.image?.cgImage
                //            }
            }()
            
            // Unwrap croppedImage and cropFrame, otherwise start up camera again and return
            guard let croppedImage = croppedImage, let cropFrame = cropFrame else {
                // TODO: Handle errors
                print("Could not get the cropped image.")
                startUpCamera()
                return
            }
            
            // Call delegate didAttachImage with croppedImage as image,
            delegate.didAttachImage(image: UIImage(cgImage: croppedImage), cropFrame: cropFrame, unmodifiedImage: previewImage)
        } else {
            // Call delegate didAttachImage with just previewImage as image
            delegate.didAttachImage(image: previewImage, cropFrame: nil, unmodifiedImage: nil)
        }
        
        // Dismiss
        delegate.dismiss()
//        self.dismiss(animated: true)
    }
    
    func scanButtonPressed() {
//        // Ensure previewImageView can be unwrapped, otherwise return
//        guard let previewImageView = previewImageView else {
//            // TODO: Handle errors
//            return
//        }
        
        // Ensure previewImage can be unwrapped, otherwise return
        guard let previewImage = previewImageView.image else {
            // TODO: Handle errors
            return
        }
        
        // Do haptic
        HapticHelper.doLightHaptic()
        
        let (croppedImage, cropFrame): (CGImage?, CGRect?) = {
            // Get the bounds of the image view and the previewImage
            let imageViewSize = previewImageView.bounds.size
            let imageSize = previewImage.size
            
            // Calculate the scale factor and the offset
            let widthScale = imageSize.width / imageViewSize.width
            let heightScale = imageSize.height / imageViewSize.height
            let scaleFactor = max(widthScale, heightScale)
            
            let scaledImageWidth = imageSize.width / scaleFactor
            let scaledImageHeight = imageSize.height / scaleFactor
            
            let imageOffsetX = (imageViewSize.width - scaledImageWidth) / 2
            let imageOffsetY = (imageViewSize.height - scaledImageHeight) / 2
            
            let cropAreaWidth = rootView.container.frame.width - rootView.cropViewLeadingConstraint.constant - rootView.cropViewTrailingConstraint.constant
            let cropAreaHeight = rootView.container.frame.height - rootView.cropViewTopConstraint.constant - rootView.cropViewBottomConstraint.constant
            
            // Calculate the cropping rectangle
            let cropFrame = CGRect(
                x: (rootView.cropViewLeadingConstraint.constant - imageOffsetX) * scaleFactor,
                y: (rootView.cropViewTopConstraint.constant - imageOffsetY) * scaleFactor,
                width: cropAreaWidth * scaleFactor,
                height: cropAreaHeight * scaleFactor
            )
            
            return (previewImageView.image?.cgImage?.cropping(to: cropFrame), cropFrame)
            //            } else {
            //                // Simply return the image as cgImage
            //                return previewImageView.image?.cgImage
            //            }
        }()
        
        // Unwrap croppedImage, otherwise start up camera again and return
        guard let croppedImage = croppedImage else {
            // TODO: Handle errors
            print("Could not get the cropped image.")
            startUpCamera()
            return
        }
        
        // For testing
//        previewImageView.contentMode = .scaleAspectFit
//        previewImageView.image = UIImage(cgImage: outputImage)
        
        // Do text recognition
        let requestHandler = VNImageRequestHandler(cgImage: croppedImage)
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
                ac.view.tintColor = UIColor(Colors.alertTintColor)
                ac.addAction(UIAlertAction(title: "Done", style: .cancel))
                self.present(ac, animated: true)
                return
            }
            
            let trimmedString = combinedStrings.trimmingCharacters(in: .whitespaces)
            
            if self.delegate != nil {
                self.delegate.didGetScan(text: trimmedString)
                self.delegate.dismiss()
//                self.dismiss(animated: true)
            }
        })
        
        request.recognitionLevel = .accurate
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func showCropViewSwitchChanged(to newValue: Bool) {
        if newValue {
            showCropView()
        } else {
            hideCropView()
        }
    }
    
}
