//
//  MockCameraManager.swift
//  Snappy
//
//  Created by Pawel Chmiel on 25.10.2016.
//  Copyright © 2016 Droids On Roids. All rights reserved.
//

import Foundation
import UIKit
@testable import Snappy

class MockCameraManager: CameraManagerProtocol {
    static var mockView : UIView?
    static var mockImage: UIImage?
    static var mockBool: Bool?
    static func generateCameraPreview(previewSize size: CGSize, completion: @escaping (_ sessionPreviewView: UIView?) -> ()) {
        completion(mockView)
    }
    
    static func switchCamera(_ completion: @escaping (_ sessionPreviewView: UIView?) -> ()) {
        completion(mockView)
    }
    
    static func toggleFlashMode(_ bool: Bool) {
        mockBool = bool
    }
    
    static func takePhoto(_ completion: @escaping (UIImage?) -> ()){
        completion(mockImage)
    }
    
}
