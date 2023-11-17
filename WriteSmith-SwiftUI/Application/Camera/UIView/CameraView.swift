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
    func attachImageButtonPressed()
    func scanButtonPressed()
    func showCropViewSwitchChanged(to newValue: Bool)
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
    
    @IBOutlet weak var showCropViewSwitchContainer: RoundedView!
    @IBOutlet weak var showCropViewSwitch: UISwitch!
    
    @IBOutlet weak var scanButtonsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scanButtonsTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var attachImageButton: RoundedButton!
    @IBOutlet weak var scanButton: RoundedButton!
    @IBOutlet weak var scanIntroText: RoundedView!
    
    @IBOutlet weak var tapToScanImageView: UIImageView!
    @IBOutlet weak var tapToScanImageViewVerticalSpaceConstraint: NSLayoutConstraint!
    
    let defaultOverlayOpacity = 0.4
    
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
    
    @IBAction func attachImageButtonPressed(_ sender: Any) {
        delegate?.attachImageButtonPressed()
    }
    
    @IBAction func showCropViewSwitchChanged(_ sender: UISwitch) {
        delegate?.showCropViewSwitchChanged(to: sender.isOn)
    }
    
}
