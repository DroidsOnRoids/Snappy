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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRemoveCameraPreview() {
        if let firstSubview = viewController?.view.subviews.first {
            viewController?.removeCameraPreview()
            XCTAssertFalse((viewController?.view.subviews.contains(firstSubview))!)
        }
    }
    
    func testInsertCameraPreview() {
        let someView = UIView()
        viewController?.insertCameraPreview(someView)
        XCTAssertTrue((viewController?.view.subviews.contains(someView))!)
    }
    
    func testZHidePhoto() {
        if let viewController = viewController, let lastSubview = viewController.view.subviews.last {
            viewController.hidePhoto()
            RunLoop.current.run(until: Date().addingTimeInterval(2.0))
            XCUIDevice.shared().press(.home)

            XCTAssertFalse((viewController.view.subviews.contains(lastSubview)))
        } else {
            XCTAssert(false)
        }
    }
    
    func testTakePhotoButtonActionWithNonNilImage() {
        MockCameraManager.mockImage = UIImage()
        MockCameraManager.takePhoto((viewController?.takePhotoCompletion)!)
        let view = viewController?.view.subviews.last
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
        XCTAssertTrue((viewController.view.subviews.contains( MockCameraManager.mockView!)))
    }
   
    func testSwitchCameraWithNilView() {
        MockCameraManager.mockView = nil
        guard let viewController = viewController else { XCTAssert(false) ; return  }
        
        let countOfSubviews = viewController.view.subviews.count
        MockCameraManager.switchCamera((viewController.switchCameraCompletion))
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



