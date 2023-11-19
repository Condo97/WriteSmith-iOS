//
//  CameraViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/30/23.
//

import AVFoundation
import UIKit
import Vision

protocol CameraViewControllerDelegate: AnyObject {
    func didAttachImage(image: UIImage, cropFrame: CGRect?, unmodifiedImage: UIImage?)
    func didGetScan(text: String)
    func dismiss()
}

class CameraViewController: UIViewController {
    
    struct InitialCropViewConstraintConstants {
        let leading = 40.0
        let trailing = 40.0
        let top = 100.0
        let bottom = 274.0
    }
    
    struct ResizeRect {
        var topTouch = false
        var leftTouch = false
        var rightTouch = false
        var bottomTouch = false
        var middleTouch = false
    }
    
    let VIEW_NAME = "CameraView"
    
    let cropViewTouchMargin = 10.0
    let cropViewMinSquare = 120.0
    
    let defaultScanButtonHeight = 52.0
    let defaultScanButtonTopSpace = 24.0
    
    let defaultScanIntroTextAlpha = 0.4
    
    var isCropInteractive = false
    
    lazy var cameraView: UIView = UIView(frame: rootView.container.bounds)
    lazy var previewImageView: UIImageView = UIImageView(frame: rootView.container.bounds)
    var resizeRect = ResizeRect()
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    var delegate: CameraViewControllerDelegate!
    
    lazy var rootView: CameraView = {
        let view = RegistryHelper.instantiateAsView(nibName: VIEW_NAME, owner: self) as! CameraView
        view.delegate = self
        return view
    }()!
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add gesture recognizer to tapToScanImageView to make it a lil easier :)
        rootView.tapToScanImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraButtonSelector)))
        
        deInitializeCropView()
        
        // Configure cameraView, previewImageView, and cameraButton
//        cameraView = UIView(frame: rootView.container.bounds)
        rootView.container.addSubview(cameraView)
        
//        previewImageView = UIImageView(frame: rootView.container.bounds)
        
        rootView.cameraButton.setBackgroundImage(UIImage(named: Constants.ImageName.cameraButtonNotPressed), for: .normal)
        
        // Setup capture device if it can be unwrapped
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
                capturePhotoOutput = AVCapturePhotoOutput()
                capturePhotoOutput?.isHighResolutionCaptureEnabled = true
                captureSession?.addOutput(capturePhotoOutput!)
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer?.frame = rootView.container.layer.bounds // View or Container?
                
                cameraView.layer.addSublayer(videoPreviewLayer!)
                
            } catch {
                print(error)
                delegate.dismiss()
//                dismiss(animated: true)
                return
            }
        }
        
        // Start capture session
        DispatchQueue.global().async {
            self.captureSession?.startRunning()
        }
        
        rootView.scanIntroText.alpha = defaultScanIntroTextAlpha
    }
    
    override func viewDidLayoutSubviews() {
        cameraView.frame = rootView.container.bounds
        videoPreviewLayer?.frame = cameraView.bounds
        
        previewImageView.frame = rootView.container.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.userDefaultNotFirstCamera) {
//            let ac = UIAlertController(title: "Important - Scan Text!", message: "Easily scan prompts, questions and more.\n\nWorks with multiple choice, true/false, and open ended question types.", preferredStyle: .alert)
            let ac = UIAlertController(title: "*NEW* - Send Images", message: "WriteSmith Can See! Introducing GPT-4-Vision. Send an image, ask questions, and get smart human-like feedback from your personal AI tutor.", preferredStyle: .alert)
            ac.view.tintColor = UIColor(Colors.alertTintColor)
            ac.addAction(UIAlertAction(title: "Confirm", style: .cancel))
            present(ac, animated: true)
            
            UserDefaults.standard.set(true, forKey: Constants.UserDefaults.userDefaultNotFirstCamera)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isCropInteractive == true else { return }
        
        // Get touches to move that crop view!
        if let touch = touches.first {
            let touchStart = touch.location(in: view)
            
            resizeRect.topTouch = false
            resizeRect.leftTouch = false
            resizeRect.rightTouch = false
            resizeRect.bottomTouch = false
            resizeRect.middleTouch = false
            
            if touchStart.y > rootView.initialImageCropZone.frame.minY + cropViewTouchMargin * 2 && touchStart.y < rootView.initialImageCropZone.frame.maxY - cropViewTouchMargin * 2 && touchStart.x > rootView.initialImageCropZone.frame.minX + cropViewTouchMargin * 2 && touchStart.x < rootView.initialImageCropZone.frame.maxX - cropViewTouchMargin * 2 {
                resizeRect.middleTouch = true
            }
            
            if touchStart.y > rootView.initialImageCropZone.frame.maxY - cropViewTouchMargin && touchStart.y < rootView.initialImageCropZone.frame.maxY + cropViewTouchMargin {
                resizeRect.bottomTouch = true
            }
            
            if touchStart.x > rootView.initialImageCropZone.frame.maxX - cropViewTouchMargin && touchStart.x < rootView.initialImageCropZone.frame.maxX + cropViewTouchMargin {
                resizeRect.rightTouch = true
            }
            
            if touchStart.x > rootView.initialImageCropZone.frame.minX - cropViewTouchMargin && touchStart.x < rootView.initialImageCropZone.frame.minX + cropViewTouchMargin {
                resizeRect.leftTouch = true
            }
            
            if touchStart.y > rootView.initialImageCropZone.frame.minY - cropViewTouchMargin && touchStart.y < rootView.initialImageCropZone.frame.minY + cropViewTouchMargin {
                resizeRect.topTouch = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isCropInteractive == true else { return }
        
        // Move that crop view!
        if let touch = touches.first {
            let currentTouchPoint = touch.location(in: view)
            let prevTouchPoint = touch.previousLocation(in: view)
            
            let deltaX = currentTouchPoint.x - prevTouchPoint.x
            let deltaY = currentTouchPoint.y - prevTouchPoint.y
            
            if resizeRect.middleTouch {
                if rootView.cropViewTopConstraint.constant + deltaY >= 0 && rootView.cropViewLeadingConstraint.constant + deltaX >= 0 && rootView.cropViewTrailingConstraint.constant - deltaX >= 0 && rootView.cropViewBottomConstraint.constant - deltaY >= 0 {
                    rootView.cropViewTopConstraint.constant += deltaY
                    rootView.cropViewLeadingConstraint.constant += deltaX
                    rootView.cropViewTrailingConstraint.constant -= deltaX
                    rootView.cropViewBottomConstraint.constant -= deltaY
                }
            }
            
            if resizeRect.topTouch && rootView.cropViewTopConstraint.constant + deltaY >= 0 && rootView.container.frame.height - (rootView.cropViewTopConstraint.constant + deltaY + rootView.cropViewBottomConstraint.constant) >= cropViewMinSquare {
                rootView.cropViewTopConstraint.constant += deltaY
            }
            
            if resizeRect.leftTouch && rootView.cropViewLeadingConstraint.constant + deltaX >= 0 && rootView.container.frame.width - (rootView.cropViewLeadingConstraint.constant + deltaX + rootView.cropViewTrailingConstraint.constant) >= cropViewMinSquare {
                rootView.cropViewLeadingConstraint.constant += deltaX
            }
            
            if resizeRect.rightTouch && rootView.cropViewTrailingConstraint.constant - deltaX >= 0 && rootView.container.frame.width - (rootView.cropViewLeadingConstraint.constant - deltaX + rootView.cropViewTrailingConstraint.constant) >= cropViewMinSquare {
                rootView.cropViewTrailingConstraint.constant -= deltaX
            }
            
            if resizeRect.bottomTouch && rootView.cropViewBottomConstraint.constant - deltaY >= 0 && rootView.container.frame.height - (rootView.cropViewTopConstraint.constant - deltaY + rootView.cropViewBottomConstraint.constant) >= cropViewMinSquare {
                rootView.cropViewBottomConstraint.constant -= deltaY
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func cameraButtonSelector() {
        // cameraButtonPressed already does a haptic, also this isn't even working rn lol
        
        cameraButtonPressed()
    }
    
    func initializeCropView(with image: UIImage, cropFrame: CGRect?, fromCamera: Bool, contentMode: UIView.ContentMode) {
        // Adjust the UI elements
        isCropInteractive = true
        
        rootView.topResizeView.alpha = 1.0
        rootView.leftResizeView.alpha = 1.0
        rootView.rightResizeView.alpha = 1.0
        rootView.bottomResizeView.alpha = 1.0
        
        rootView.scanIntroText.alpha = 0.0
        
        // Adjust overlay views if cropFrame is provided
        if let cropFrame = cropFrame {
            // First, set the contentMode and image for the previewImageView as usual.
                   previewImageView.contentMode = contentMode
                   previewImageView.image = image
            
                   // Calculate the crop view constraints based on the cropFrame
                   let imageViewSize = previewImageView.bounds.size
                   let imageSize = image.size
                   let widthScale = imageSize.width / imageViewSize.width
                   let heightScale = imageSize.height / imageViewSize.height
                   let scaleFactor = max(widthScale, heightScale)

                   // Deriving the constraints values from the reverse operation of the cropping process.
                   rootView.cropViewLeadingConstraint.constant = (cropFrame.minX / scaleFactor)
                   rootView.cropViewTopConstraint.constant = (cropFrame.minY / scaleFactor)
                   rootView.cropViewTrailingConstraint.constant = imageViewSize.width - (cropFrame.maxX / scaleFactor)
                   rootView.cropViewBottomConstraint.constant = imageViewSize.height - (cropFrame.maxY / scaleFactor)

                   // Ensure the constraints are updated.
                   self.view.layoutIfNeeded()
        } else {
            // Use default if no specific cropping frame is provided
            rootView.cropViewTopConstraint.constant = InitialCropViewConstraintConstants().top
            rootView.cropViewLeadingConstraint.constant = InitialCropViewConstraintConstants().leading
            rootView.cropViewTrailingConstraint.constant = InitialCropViewConstraintConstants().trailing
            rootView.cropViewBottomConstraint.constant = InitialCropViewConstraintConstants().bottom
        }
        
        // Hide Tap to Scan button
        UIView.animate(withDuration: 0.2, animations: {
            self.rootView.tapToScanImageView.alpha = 0.0
        })
        
        // Show "Scan Selection" and "Attach Image" buttons
//        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
        self.rootView.attachImageButton.alpha = 1.0
        self.rootView.scanButton.alpha = 1.0
        
        self.rootView.scanButtonsHeightConstraint.constant = self.defaultScanButtonHeight
        self.rootView.scanButtonsTopSpaceConstraint.constant = self.defaultScanButtonTopSpace
        
        // TODO: Should and can these be coombined into an update to the container instead?
        self.rootView.attachImageButton.setNeedsDisplay()
        self.rootView.scanButton.setNeedsDisplay()
        
        // Show show crop view switch
        self.rootView.showCropViewSwitchContainer.alpha = 0.8
        self.rootView.showCropViewSwitchContainer.setNeedsDisplay()
//        })
        
        // Ensure the capture session has stopped
        captureSession?.stopRunning()
        cameraView.removeFromSuperview()
        
        var orientation: UIImage.Orientation
        var imageToSave: UIImage
        if fromCamera {
            // Set the image in the crop view
            let width = image.size.width
            let height = image.size.height
            let origin = CGPoint(x: ((height - width * 9/6))/2, y: (height - height)/2)
            let size = CGSize(width: width * 9/6, height: width)
            
            guard let imageRef = image.cgImage?.cropping(to: CGRect(origin: origin, size: size)) else {
                print("Fail to crop image")
                return
            }
            
            let imageToRotate = UIImage(cgImage: imageRef, scale: 1.0, orientation: .up)
            imageToSave = imageToRotate.rotated(radians: .pi / 2)!
        } else {
            imageToSave = image
            orientation = .up
        }
        
        previewImageView.contentMode = contentMode
        previewImageView.image = imageToSave
        rootView.container.addSubview(previewImageView)
        
        rootView.cameraButton.setBackgroundImage(UIImage(named: Constants.ImageName.cameraButtonRedo), for: .normal)
    }
    
    func deInitializeCropView() {
        // Adjust the UI elements
        isCropInteractive = false
        
        rootView.topResizeView.alpha = 0.0
        rootView.leftResizeView.alpha = 0.0
        rootView.rightResizeView.alpha = 0.0
        rootView.bottomResizeView.alpha = 0.0
        
        rootView.scanIntroText.alpha = defaultScanIntroTextAlpha
        
        rootView.cropViewTopConstraint.constant = InitialCropViewConstraintConstants().top
        rootView.cropViewLeadingConstraint.constant = InitialCropViewConstraintConstants().leading
        rootView.cropViewTrailingConstraint.constant = InitialCropViewConstraintConstants().trailing
        rootView.cropViewBottomConstraint.constant = InitialCropViewConstraintConstants().bottom
        
        //TODO: - Smoother animation
        self.rootView.attachImageButton.alpha = 0.0
        self.rootView.scanButton.alpha = 0.0
        self.rootView.scanButtonsHeightConstraint.constant = 0.0
        self.rootView.scanButtonsTopSpaceConstraint.constant = 0.0
        self.rootView.showCropViewSwitchContainer.alpha = 0.0
        self.rootView.attachImageButton.setNeedsDisplay()
        self.rootView.scanButton.setNeedsDisplay()
        self.rootView.showCropViewSwitchContainer.setNeedsDisplay()
    }
    
    func showCropView() {
        // Set cropView element opacity to 1.0
        rootView.topResizeView.alpha = 1.0
        rootView.leftResizeView.alpha = 1.0
        rootView.rightResizeView.alpha = 1.0
        rootView.bottomResizeView.alpha = 1.0
        
        rootView.topOverlay.alpha = rootView.defaultOverlayOpacity
        rootView.leftOverlay.alpha = rootView.defaultOverlayOpacity
        rootView.rightOverlay.alpha = rootView.defaultOverlayOpacity
        rootView.bottomOverlay.alpha = rootView.defaultOverlayOpacity
        rootView.initialImageCropZone.alpha = 1.0
    }
    
    func hideCropView() {
        // Set cropView element opacity to 0.0
        rootView.topResizeView.alpha = 0.0
        rootView.leftResizeView.alpha = 0.0
        rootView.rightResizeView.alpha = 0.0
        rootView.bottomResizeView.alpha = 0.0
        
        rootView.topOverlay.alpha = 0.0
        rootView.leftOverlay.alpha = 0.0
        rootView.rightOverlay.alpha = 0.0
        rootView.bottomOverlay.alpha = 0.0
        rootView.initialImageCropZone.alpha = 0.0
    }
    
    func startUpCameraAgain() {
        if previewImageView != nil && previewImageView.isDescendant(of: rootView.container) {
            previewImageView.removeFromSuperview()
        }
        
        rootView.container.addSubview(cameraView)
        
        captureSession?.startRunning()
        
        rootView.cameraButton.setBackgroundImage(UIImage(named: Constants.ImageName.cameraButtonNotPressed), for: .normal)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Couldn't capture phtoto: \(String(describing: error))")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Failed to convert pixel buffer")
            return
        }
        
        guard let capturedImage = UIImage.init(data: imageData, scale: 1.0) else {
            print("Failed to convert image data to UIImage")
            return
        }
        
        captureSession?.stopRunning()
        cameraView.removeFromSuperview()
        
//        let width = capturedImage.size.width
//        let height = capturedImage.size.height
//        let origin = CGPoint(x: ((height - width * 9/6))/2, y: (height - height)/2)
//        let size = CGSize(width: width * 9/6, height: width)
//        
//        guard let imageRef = capturedImage.cgImage?.cropping(to: CGRect(origin: origin, size: size)) else {
//            print("Fail to crop image")
//            return
//        }
//        
//        let imageToSave = UIImage(cgImage: imageRef, scale: 1.0, orientation: .right)
        
        rootView.cameraButton.setBackgroundImage(UIImage(named: Constants.ImageName.cameraButtonRedo), for: .normal)
        
        // Setup Crop View
        initializeCropView(with: capturedImage, cropFrame: nil, fromCamera: true, contentMode: .scaleAspectFill)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            captureSession?.stopRunning()
            cameraView.removeFromSuperview()
            
//            let width = image.size.width
//            let height = image.size.height
//            let origin = CGPoint(x: (height - height)/2, y: ((height - width * 9/6))/2)
//            let size = CGSize(width: width, height: width * 9/6)
//            
//            guard let imageRef = image.cgImage?.cropping(to: CGRect(origin: origin, size: size)) else {
//                print("Fail to crop image")
//                return
//            }
//            
//            let imageToSave = UIImage(cgImage: imageRef, scale: 1.0, orientation: .up)
            
            initializeCropView(with: image, cropFrame: nil, fromCamera: false, contentMode: .scaleAspectFit)
            
            rootView.cameraButton.setBackgroundImage(UIImage(named: Constants.ImageName.cameraButtonRedo), for: .normal)
        } else {
            let ac = UIAlertController(title: "Could Not Get Image", message: "There was an issue getting your image. Please try again.", preferredStyle: .alert)
            ac.view.tintColor = UIColor(Colors.alertTintColor)
            ac.addAction(UIAlertAction(title: "Done", style: .cancel))
            present(ac, animated: true)
        }
    }
}
