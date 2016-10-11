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
    
    static func generateCameraPreview(previewSize size: CGSize, completion: @escaping (_ sessionPreviewView: UIView?) -> ())
    static func switchCamera(_ completion: @escaping (_ sessionPreviewView: UIView?) -> ()) 
    static func toggleFlashMode(_ bool: Bool)
    static func takePhoto(_ completion: @escaping (UIImage?) -> ())
    
}
