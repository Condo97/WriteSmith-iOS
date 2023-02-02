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
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var initialImageCropZone: RoundedView!
    
    @IBOutlet weak var cropViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cropViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cropViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cropViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topResizeView: RoundedView!
    @IBOutlet weak var leftResizeView: RoundedView!
    @IBOutlet weak var rightResizeView: RoundedView!
    @IBOutlet weak var bottomResizeView: RoundedView!
    
    @IBOutlet weak var topOverlay: UIView!
    @IBOutlet weak var leftOverlay: UIView!
    @IBOutlet weak var rightOverlay: UIView!
    @IBOutlet weak var bottomOverlay: UIView!
    
    @IBOutlet weak var scanButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scanButtonTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scanButton: RoundedButton!
    @IBOutlet weak var scanIntroText: RoundedView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            dismiss(animated: true)
            return
        }
        
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
            videoPreviewLayer?.frame = container.layer.bounds // View or Container?
            
            cameraView = UIView(frame: container.bounds)
            cameraView.layer.addSublayer(videoPreviewLayer!)
            container.addSubview(cameraView)
            
            previewImageView = UIImageView(frame: container.bounds)
            
            cameraButton.setBackgroundImage(UIImage(named: Constants.cameraButtonNotPressedImageName), for: .normal)
            
            captureSession?.startRunning()
            
        } catch {
            print(error)
            dismiss(animated: true)
            return
        }
        
        scanIntroText.alpha = defaultScanIntroTextAlpha
    }
    
    override func viewDidLayoutSubviews() {
        cameraView.frame = container.bounds
        videoPreviewLayer?.frame = cameraView.bounds
        
        previewImageView.frame = container.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: Constants.userDefaultFirstTimeCamera) {
            let ac = UIAlertController(title: "Important - Scan Text!", message: "Easily scan prompts, questions and more.\n\nWorks with multiple choice, true/false, and open ended question types.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Confirm", style: .cancel))
            present(ac, animated: true)
            
            UserDefaults.standard.set(true, forKey: Constants.userDefaultFirstTimeCamera)
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
            
            if touchStart.y > initialImageCropZone.frame.minY + cropViewTouchMargin * 2 && touchStart.y < initialImageCropZone.frame.maxY - cropViewTouchMargin * 2 && touchStart.x > initialImageCropZone.frame.minX + cropViewTouchMargin * 2 && touchStart.x < initialImageCropZone.frame.maxX - cropViewTouchMargin * 2 {
                resizeRect.middleTouch = true
            }
            
            if touchStart.y > initialImageCropZone.frame.maxY - cropViewTouchMargin && touchStart.y < initialImageCropZone.frame.maxY + cropViewTouchMargin {
                resizeRect.bottomTouch = true
            }
            
            if touchStart.x > initialImageCropZone.frame.maxX - cropViewTouchMargin && touchStart.x < initialImageCropZone.frame.maxX + cropViewTouchMargin {
                resizeRect.rightTouch = true
            }
            
            if touchStart.x > initialImageCropZone.frame.minX - cropViewTouchMargin && touchStart.x < initialImageCropZone.frame.minX + cropViewTouchMargin {
                resizeRect.leftTouch = true
            }
            
            if touchStart.y > initialImageCropZone.frame.minY - cropViewTouchMargin && touchStart.y < initialImageCropZone.frame.minY + cropViewTouchMargin {
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
                if cropViewTopConstraint.constant + deltaY >= 0 && cropViewLeadingConstraint.constant + deltaX >= 0 && cropViewTrailingConstraint.constant - deltaX >= 0 && cropViewBottomConstraint.constant - deltaY >= 0 {
                    cropViewTopConstraint.constant += deltaY
                    cropViewLeadingConstraint.constant += deltaX
                    cropViewTrailingConstraint.constant -= deltaX
                    cropViewBottomConstraint.constant -= deltaY
                }
            }
            
            if resizeRect.topTouch && cropViewTopConstraint.constant + deltaY >= 0 && container.frame.height - (cropViewTopConstraint.constant + deltaY + cropViewBottomConstraint.constant) >= cropViewMinSquare {
                cropViewTopConstraint.constant += deltaY
            }
            
            if resizeRect.leftTouch && cropViewLeadingConstraint.constant + deltaX >= 0 && container.frame.width - (cropViewLeadingConstraint.constant + deltaX + cropViewTrailingConstraint.constant) >= cropViewMinSquare {
                cropViewLeadingConstraint.constant += deltaX
            }
            
            if resizeRect.rightTouch && cropViewTrailingConstraint.constant - deltaX >= 0 && container.frame.width - (cropViewLeadingConstraint.constant - deltaX + cropViewTrailingConstraint.constant) >= cropViewMinSquare {
                cropViewTrailingConstraint.constant -= deltaX
            }
            
            if resizeRect.bottomTouch && cropViewBottomConstraint.constant - deltaY >= 0 && container.frame.height - (cropViewTopConstraint.constant - deltaY + cropViewBottomConstraint.constant) >= cropViewMinSquare {
                cropViewBottomConstraint.constant -= deltaY
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        if cameraButton.backgroundImage(for: .normal) == UIImage(named: Constants.cameraButtonNotPressedImageName) || cameraButton.backgroundImage(for: .normal) == UIImage(named: Constants.cameraButtonPressedImageName) {
            // Camera was enabled, so take the photo
            guard let capturePhotoOutput = self.capturePhotoOutput else { return }
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.flashMode = .auto
            
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        } else {
            // Camera was not enabled, so delete the picture and redo
            startUpCameraAgain()
            deInitializeCropView()
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func imageButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true)
        }
    }
    
    @IBAction func scanButton(_ sender: Any) {
        // Get the output image
        let scale = max((previewImageView.image?.size.width)! / container.frame.width, (previewImageView.image?.size.height)! / container.frame.height)
        
        guard let outputImage = previewImageView.image?.cgImage?.cropping(to: CGRect(x: cropViewLeadingConstraint.constant * scale, y: cropViewTopConstraint.constant * scale, width: (container.frame.width - cropViewLeadingConstraint.constant - cropViewTrailingConstraint.constant) * scale, height: (container.frame.height - cropViewTopConstraint.constant - cropViewBottomConstraint.constant) * scale)) else {
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
            
            if self.delegate != nil {
                self.delegate.didGetScan(text: combinedStrings)
                self.dismiss(animated: true)
            }
        })
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func initializeCropView(with image: UIImage, _ fromCamera: Bool, _ contentMode: UIView.ContentMode) {
        // Adjust the UI elements
        shouldCrop = true
        
        topResizeView.alpha = 1.0
        leftResizeView.alpha = 1.0
        rightResizeView.alpha = 1.0
        bottomResizeView.alpha = 1.0
        
        scanIntroText.alpha = 0.0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, animations: {
            self.scanButton.alpha = 1.0
            self.scanButtonHeightConstraint.constant = self.defaultScanButtonHeight
            self.scanButtonTopSpaceConstraint.constant = self.defaultScanButtonTopSpace
            
            self.scanButton.setNeedsDisplay()
        })
        
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
        container.addSubview(previewImageView)
        
        cameraButton.setBackgroundImage(UIImage(named: Constants.cameraButtonRedo), for: .normal)
    }
    
    func deInitializeCropView() {
        // Adjust the UI elements
        shouldCrop = false
        
        topResizeView.alpha = 0.0
        leftResizeView.alpha = 0.0
        rightResizeView.alpha = 0.0
        bottomResizeView.alpha = 0.0
        
        scanIntroText.alpha = defaultScanIntroTextAlpha
        
        cropViewTopConstraint.constant = InitialCropViewConstraintConstants().top
        cropViewLeadingConstraint.constant = InitialCropViewConstraintConstants().leading
        cropViewTrailingConstraint.constant = InitialCropViewConstraintConstants().trailing
        cropViewBottomConstraint.constant = InitialCropViewConstraintConstants().bottom
        
        //TODO: - Smoother animation
        self.scanButton.alpha = 0.0
        self.scanButtonHeightConstraint.constant = 0.0
        self.scanButtonTopSpaceConstraint.constant = 0.0
        self.scanButton.setNeedsDisplay()
    }
    
    func startUpCameraAgain() {
        if previewImageView != nil && previewImageView.isDescendant(of: container) {
            previewImageView.removeFromSuperview()
        }
        
        container.addSubview(cameraView)
        
        captureSession?.startRunning()
        
        cameraButton.setBackgroundImage(UIImage(named: Constants.cameraButtonNotPressedImageName), for: .normal)
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
        
        cameraButton.setBackgroundImage(UIImage(named: Constants.cameraButtonRedo), for: .normal)
        
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
            
            cameraButton.setBackgroundImage(UIImage(named: Constants.cameraButtonRedo), for: .normal)
        } else {
            let ac = UIAlertController(title: "Could Not Get Image", message: "There was an issue getting your image. Please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Done", style: .cancel))
            present(ac, animated: true)
        }
    }
}
