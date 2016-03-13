//
//  PhotoViewController.swift
//  Snappy
//
//  Created by Lukasz Mroz on 13.03.2016.
//  Copyright © 2016 Droids On Roids. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        let screenFrame = UIScreen.mainScreen().bounds
        let previewDimension = CGSize(width: CGRectGetWidth(screenFrame), height: CGRectGetHeight(screenFrame))
        
        CameraManager.generateCameraPreview(previewSize: previewDimension) { [unowned self] sessionPreview in
            guard let preview = sessionPreview, firstSubview = self.view.subviews.first else { return }
            self.view.insertSubview(preview, belowSubview: firstSubview)
        }
    }
    
}
