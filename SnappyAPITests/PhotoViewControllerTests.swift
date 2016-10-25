//
//  PhotoViewControllerTests.swift
//  Snappy
//
//  Created by Pawel Chmiel on 18.10.2016.
//  Copyright © 2016 Droids On Roids. All rights reserved.
//

import XCTest
@testable import Snappy

class PhotoViewControllerTests: XCTestCase {
   
    var viewController  : PhotoViewController?
   
    override func setUp() {
        super.setUp()
        if viewController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            viewController = storyboard.instantiateViewController(withIdentifier: "middle") as? PhotoViewController
            UIApplication.shared.keyWindow?.rootViewController = viewController
            
            let _ = viewController?.view
        }
    }
    
    func testRemoveCameraPreview() {
        if  let viewController = viewController, let firstSubview = viewController.view.subviews.first {
            viewController.removeCameraPreview()
            XCTAssertFalse(viewController.view.subviews.contains(firstSubview))
        }
    }
    
    func testInsertCameraPreview() {
        let someView = UIView()
        guard let viewController = viewController else { XCTAssert(false) ; return  }
      
        viewController.insertCameraPreview(someView)
        XCTAssertTrue(viewController.view.subviews.contains(someView))
    }
    
    func testZHidePhoto() {
        if let viewController = viewController, let lastSubview = viewController.view.subviews.last {
            viewController.hidePhoto()
            RunLoop.current.run(until: Date().addingTimeInterval(2.0))
            XCUIDevice.shared().press(.home)
            XCTAssertFalse(viewController.view.subviews.contains(lastSubview))
        } else {
            XCTAssert(false)
        }
    }
    
    func testTakePhotoButtonActionWithNonNilImage() {
        MockCameraManager.mockImage = UIImage()
        guard let viewController = viewController else { XCTAssert(false) ; return  }
    
        MockCameraManager.takePhoto(viewController.takePhotoCompletion)
        let view = viewController.view.subviews.last
        XCTAssertTrue(view?.classForCoder == UIImageView.classForCoder())
    }
  
    func testTakePhotoButtonActionWithNilImage() {
        MockCameraManager.mockImage = nil
        guard let viewController = viewController else { XCTAssert(false) ; return }
    
        MockCameraManager.takePhoto((viewController.takePhotoCompletion))
        let view = viewController.view.subviews.last
        XCTAssertFalse(view?.classForCoder == UIImageView.classForCoder())
    }
    
    func testSwitchCamera() {
        MockCameraManager.mockView = UIView()
        guard let viewController = viewController else { XCTAssert(false) ; return  }
        
        MockCameraManager.switchCamera((viewController.switchCameraCompletion))
        XCTAssertTrue(viewController.view.subviews.contains(MockCameraManager.mockView!))
    }
   
    func testSwitchCameraWithNilView() {
        MockCameraManager.mockView = nil
        guard let viewController = viewController else { XCTAssert(false) ; return  }
        
        let countOfSubviews = viewController.view.subviews.count
        MockCameraManager.switchCamera(viewController.switchCameraCompletion)
        XCTAssertEqual(countOfSubviews, viewController.view.subviews.count)
    }
    
    func testFlashButtonAction() {
        MockCameraManager.toggleFlashMode(true)
        XCTAssertTrue(MockCameraManager.mockBool!)
    }
    
    func testFlashButtonActionFalse() {
        MockCameraManager.toggleFlashMode(false)
        XCTAssertFalse(MockCameraManager.mockBool!)
    }
    
}
