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
    
    private var currentFlashMode: Bool = false
    private let screenFrame = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadSetup()
    }
    
    func viewDidLoadSetup() {
        let previewDimension = CGSize(width: CGRectGetWidth(screenFrame), height: CGRectGetHeight(screenFrame))
        
        CameraManager.generateCameraPreview(previewSize: previewDimension) { [unowned self] sessionPreview in
            self.insertCameraPreview(sessionPreview)
        }
    }
    
// MARK: Methods
    
    func removeCameraPreview() {
        guard let firstSubview = view.subviews.first else { return }
        firstSubview.removeFromSuperview()
    }
    
    func insertCameraPreview(generatedPreview: UIView?) {
        guard let preview = generatedPreview, firstSubview = view.subviews.first else { return }
        view.insertSubview(preview, belowSubview: firstSubview)
    }
    
    func hidePhoto() {
        guard let lastSubview = view.subviews.last else { return }
        UIView.animateWithDuration(1.0,
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
    
    @IBAction func takePhotoButtonAction(sender: AnyObject) {
        CameraManager.takePhoto { photo in
            guard let image = photo else { return }
            let imageView  = UIImageView(frame: CGRect(
                x: 0.0,
                y: 0.0,
                width: CGRectGetWidth(self.screenFrame),
                height: CGRectGetHeight(self.screenFrame)))
            imageView.contentMode = .ScaleAspectFill
            imageView.image = image
            
            self.view.addSubview(imageView)
            
            NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "hidePhoto", userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func switchCameraButtonAction(sender: AnyObject) {
        removeCameraPreview()
        
        CameraManager.switchCamera { [unowned self] sessionPreview in
            self.insertCameraPreview(sessionPreview)
        }
    }
    
    @IBAction func flashButtonAction(sender: AnyObject) {
        currentFlashMode = !currentFlashMode
        flashButton.setImage(UIImage(named: currentFlashMode ? "FlashButtonImage" : "FlashOffButtonImage"), forState: .Normal)
        
        CameraManager.toggleFlashMode(currentFlashMode)
    }
    
}
