//
//  CameraView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import UIKit

protocol CameraViewDelegate {
    func cameraButtonPressed()
    func cancelButtonPressed()
    func imageButtonPressed()
    func scanButtonPressed()
}

class CameraView: UIView {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var initialImageCropZone: SillyCropView!
    
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
    
    @IBOutlet weak var tapToScanImageView: UIImageView!
    @IBOutlet weak var tapToScanImageViewVerticalSpaceConstraint: NSLayoutConstraint!
    
    var delegate: CameraViewDelegate?
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        delegate?.cameraButtonPressed()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        delegate?.cancelButtonPressed()
    }
    
    @IBAction func imageButtonPressed(_ sender: Any) {
        delegate?.imageButtonPressed()
    }
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        delegate?.scanButtonPressed()
    }
    
}
