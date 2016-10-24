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

    func testZTakePhoto() {
        let exp = expectation(description: "take photo")
        CameraManager.takePhoto { image in
            if let image = image {
                XCTAssertTrue(image.size.width > 1000)
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testAToggleFlashMode() {
        if let device = (CameraManager.session!.inputs.first as! AVCaptureDeviceInput).device {
            if device.position == .back {
                CameraManager.toggleFlashMode(true)
                XCTAssertTrue(device.flashMode == .on)
            }
        }
    }
    
    func testSwitchCameraToFront() {
        let exp = expectation(description: "front camera")
        if let camera = CameraManager.session?.inputs.first as? AVCaptureDeviceInput {
            if camera.device.position == .back {
                CameraManager.switchCamera({ _ in
                   XCTAssertTrue((CameraManager.session!.inputs.first as! AVCaptureDeviceInput ).device.position == .front)
                    exp.fulfill()
                })
            } else {
                CameraManager.switchCamera({ _ in
                    XCTAssertTrue((CameraManager.session!.inputs.first as! AVCaptureDeviceInput ).device.position == .back)
                    exp.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
}
