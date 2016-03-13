//
//  CameraManagerProtocol.swift
//  CameraAVFoundation
//
//  Created by Paweł Sternik on 06.03.2016.
//  Copyright © 2016 PawelSternik. All rights reserved.
//

import Foundation
import UIKit

protocol CameraManagerProtocol {
    
    static func generateCameraPreview(previewSize size: CGSize, completion: (sessionPreviewView: UIView?) -> ())
    static func switchCamera(completion: (sessionPreviewView: UIView?) -> ())
    static func toggleFlashMode(bool: Bool)
    static func takePhoto(completion: (UIImage?) -> ())
    
}