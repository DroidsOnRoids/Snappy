//
//  CameraManagerTests.swift
//  Snappy
//
//  Created by Pawel Chmiel on 18.10.2016.
//  Copyright © 2016 Droids On Roids. All rights reserved.
//

import XCTest
import AVFoundation
@testable import Snappy

class CameraManagerTests: XCTestCase {
    
    var previewSize = CGSize(width: 200, height: 300)
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScaleImage() {
        let image = UIImage().scaledToSize(previewSize)
        XCTAssertTrue(image.size.width == 200 && image.size.height == 300)
    }
    
    func testSetCamera() {
        CameraManager.generateCameraPreview(previewSize: previewSize) { view in
            XCTAssertTrue(view == CameraManager.previewView)
        }
    }
    
    func testWorkingOutput() {
        CameraManager.generateCameraPreview(previewSize: previewSize) { view in
            XCTAssertNotNil(view)
        }
    }
    
    func testSwitchCamera() {
        CameraManager.switchCamera { view in
            XCTAssertNotNil(view)
        }
    }
    
    func testToggleFlash() {
        CameraManager.session = nil
        CameraManager.toggleFlashMode(true)
        
        
    }
}
