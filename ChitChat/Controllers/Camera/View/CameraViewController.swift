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
    func didGetScan(text: String)
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
    
    let cropViewTouchMargin = 10.0
    let cropViewMinSquare = 120.0
    
    let defaultScanButtonHeight = 52.0
    let defaultScanButtonTopSpace = 24.0
    
    let defaultScanIntroTextAlpha = 0.4
    
    var shouldCrop = false
    
    var cameraView: UIView!
    var previewImageView: UIImageView!
    var resizeRect = ResizeRect()
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    var delegate: CameraViewControllerDelegate!
    
    lazy var rootView: CameraView = {
        let view = RegistryHelper.instantiateAsView(nibName: Registry.Camera.View.camera, owner: self) as! CameraView
        view.delegate = self
        return view
    }()!
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            dismiss(animated: true)
            return
        }
        
        // Add gesture recognizer to tapToScanImageView to make it a lil easier :)
        rootView.tapToScanImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraButtonSelector)))
        
        deInitializeCropView()
        
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
            
            cameraView = UIView(frame: rootView.container.bounds)
            cameraView.layer.addSublayer(videoPreviewLayer!)
            rootView.container.addSubview(cameraView)
            
            previewImageView = UIImageView(frame: rootView.container.bounds)
            
            rootView.cameraButton.setBackgroundImage(UIImage(named: Constants.ImageName.cameraButtonNotPressed), for: .normal)
            
            DispatchQueue.global().async {
                self.captureSession?.startRunning()
            }
            
        } catch {
            print(error)
            dismiss(animated: true)
            return
        }
        
        rootView.scanIntroText.alpha = defaultScanIntroTextAlpha
    }
    
    override func viewDidLayoutSubviews() {
        cameraView.frame = rootView.container.bounds
        videoPreviewLayer?.frame = cameraView.bounds
        
        previewImageView.frame = rootView.container.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultNotFirstCamera) {
            let ac = UIAlertController(title: "Important - Scan Text!", message: "Easily scan prompts, questions and more.\n\nWorks with multiple choice, true/false, and open ended question types.", preferredStyle: .alert)
            ac.view.tintColor = Colors.alertTintColor
            ac.addAction(UIAlertAction(title: "Confirm", style: .cancel))
            present(ac, animated: true)
            
            UserDefaults.standard.set(true, forKey: Constants.userDefaultNotFirstCamera)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard shouldCrop == true else { return }
        
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
        guard shouldCrop == true else { return }
        
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
    
    func initializeCropView(with image: UIImage, _ fromCamera: Bool, _ contentMode: UIView.ContentMode) {
        // Adjust the UI elements
        shouldCrop = true
        
        rootView.topResizeView.alpha = 1.0
        rootView.leftResizeView.alpha = 1.0
        rootView.rightResizeView.alpha = 1.0
        rootView.bottomResizeView.alpha = 1.0
        
        rootView.scanIntroText.alpha = 0.0
        
        // Hide Tap to Scan button
        UIView.animate(withDuration: 0.2, animations: {
            self.rootView.tapToScanImageView.alpha = 0.0
        })
        
        // Show "Scan Selection" button
//        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
        self.rootView.scanButton.alpha = 1.0
        self.rootView.scanButtonHeightConstraint.constant = self.defaultScanButtonHeight
        self.rootView.scanButtonTopSpaceConstraint.constant = self.defaultScanButtonTopSpace
        
        self.rootView.scanButton.setNeedsDisplay()
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
        
//        imageToSave = UIImage(cgImage: imageRefToSave, scale: 1.0, orientation: orientation)
        
        previewImageView.contentMode = contentMode
        previewImageView.image = imageToSave
        rootView.container.addSubview(previewImageView)
        
        rootView.cameraButton.setBackgroundImage(UIImage(named: Constants.ImageName.cameraButtonRedo), for: .normal)
    }
    
    func deInitializeCropView() {
        // Adjust the UI elements
        shouldCrop = false
        
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
        self.rootView.scanButton.alpha = 0.0
        self.rootView.scanButtonHeightConstraint.constant = 0.0
        self.rootView.scanButtonTopSpaceConstraint.constant = 0.0
        self.rootView.scanButton.setNeedsDisplay()
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
        
        let width = capturedImage.size.width
        let height = capturedImage.size.height
        let origin = CGPoint(x: ((height - width * 9/6))/2, y: (height - height)/2)
        let size = CGSize(width: width * 9/6, height: width)
        
        guard let imageRef = capturedImage.cgImage?.cropping(to: CGRect(origin: origin, size: size)) else {
            print("Fail to crop image")
            return
        }
        
        let imageToSave = UIImage(cgImage: imageRef, scale: 1.0, orientation: .right)
        
        rootView.cameraButton.setBackgroundImage(UIImage(named: Constants.ImageName.cameraButtonRedo), for: .normal)
        
        // Setup Crop View
        initializeCropView(with: imageToSave, true, .scaleAspectFill)
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
            
            let width = image.size.width
            let height = image.size.height
            let origin = CGPoint(x: (height - height)/2, y: ((height - width * 9/6))/2)
            let size = CGSize(width: width, height: width * 9/6)
            
            guard let imageRef = image.cgImage?.cropping(to: CGRect(origin: origin, size: size)) else {
                print("Fail to crop image")
                return
            }
            
            let imageToSave = UIImage(cgImage: imageRef, scale: 1.0, orientation: .up)
            
            initializeCropView(with: imageToSave, false, .scaleAspectFill)
            
            rootView.cameraButton.setBackgroundImage(UIImage(named: Constants.ImageName.cameraButtonRedo), for: .normal)
        } else {
            let ac = UIAlertController(title: "Could Not Get Image", message: "There was an issue getting your image. Please try again.", preferredStyle: .alert)
            ac.view.tintColor = Colors.alertTintColor
            ac.addAction(UIAlertAction(title: "Done", style: .cancel))
            present(ac, animated: true)
        }
    }
}
