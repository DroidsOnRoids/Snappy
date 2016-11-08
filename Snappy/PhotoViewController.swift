//
//  PhotoViewController.swift
//  Snappy
//
//  Created by Lukasz Mroz on 13.03.2016.
//  Copyright © 2016 Droids On Roids. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    fileprivate var currentFlashMode = false
    fileprivate let screenFrame = UIScreen.main.bounds
    
    lazy var takePhotoCompletion: ((UIImage?) -> ()) = { [weak self] photo in
        guard let `self` = self, let image = photo else { return }
        let imageView  = UIImageView(frame: CGRect(
            x: 0.0,
            y: 0.0,
            width: self.screenFrame.width,
            height: self.screenFrame.height))
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        
        self.view.addSubview(imageView)
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(PhotoViewController.hidePhoto), userInfo: nil, repeats: false)
    }
    
    lazy var switchCameraCompletion : ((UIView?) -> ()) = { [unowned self] sessionPreview in
        self.insertCameraPreview(sessionPreview)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadSetup()
    }
    
    func viewDidLoadSetup() {
        let previewDimension = CGSize(width: screenFrame.width, height: screenFrame.height)
        
        CameraManager.generateCameraPreview(previewSize: previewDimension) { [unowned self] sessionPreview in
            self.insertCameraPreview(sessionPreview)
        }
    }
    
// MARK: Methods
    
    func removeCameraPreview() {
        guard let firstSubview = view.subviews.first else { return }
        firstSubview.removeFromSuperview()
    }
    
    func insertCameraPreview(_ generatedPreview: UIView?) {
        guard let preview = generatedPreview, let firstSubview = view.subviews.first else { return }
        view.insertSubview(preview, belowSubview: firstSubview)
    }
    
    func hidePhoto() {
        guard let lastSubview = view.subviews.last else { return }
        UIView.animate(withDuration: 1.0,
            animations: {
                lastSubview.alpha = 0.0
            },
            completion: { finished in
                if finished {
                    lastSubview.removeFromSuperview()
                }
        })
    }
    
// MARK: Actions
   
    @IBAction func takePhotoButtonAction(_ sender: AnyObject) {
        CameraManager.takePhoto(takePhotoCompletion)
    }
    
    @IBAction func switchCameraButtonAction(_ sender: AnyObject) {
        removeCameraPreview()
        CameraManager.switchCamera(switchCameraCompletion)
    }
    
    @IBAction func flashButtonAction(_ sender: AnyObject) {
        currentFlashMode = !currentFlashMode
        flashButton.setImage(UIImage(named: currentFlashMode ? "FlashButtonImage" : "FlashOffButtonImage"), for: .normal)
        
        CameraManager.toggleFlashMode(currentFlashMode)
    }
    
}
