//
//  SnappyAPITests.swift
//  SnappyAPITests
//
//  Created by Pawel Chmiel on 11.10.2016.
//  Copyright © 2016 Droids On Roids. All rights reserved.
//

import XCTest
import Alamofire
@testable import Snappy

class ASnappyAPITests: XCTestCase {
    
    func testUploadToUser() {
        let expectationUploadForSpecificUser = expectation(description: "upload image for specific user")
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        var result : Result<Any>?
        
        if let image = image {
            SnapchatAPI.upload(image: image, toUser: 11, completion: { response in
                switch response {
                case .success:
                    result = response
                case .failure:
                    XCTAssert(false)
                }
                expectationUploadForSpecificUser.fulfill()
            })
        } else {
            XCTAssert(false)
        }
        
        waitForExpectations(timeout: 5.0, handler: { error in
            XCTAssert((result?.value != nil))
        })
    }
    
    func testGetAllImages() {
        let expectationGetAllImages = expectation(description: "getting all images")
        var imageArray : [Any]?
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                let responseDict = response as? [String: Any]
                imageArray = responseDict?["images"] as? [[String: Any]]
            case .failure:
                XCTAssert(false)
            }
            
            expectationGetAllImages.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: { error in
            XCTAssertTrue(imageArray!.count > 0)
        })
    }
    
    func testAUploadImage() {
        let expectationUploadImage = expectation(description: "upload image")
        
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        var result : Result<Any>?
       
        if let image = image {
            SnapchatAPI.upload(image: image, completion: { response in
                switch response {
                case .success:
                    result = response
                case .failure:
                    XCTAssert(false)
                }
                expectationUploadImage.fulfill()
            })
        } else {
            XCTAssert(false)
        }

        waitForExpectations(timeout: 5.0, handler: { error in
             XCTAssert((result?.value != nil))
        })
    }
    
    func testDownloadImage() {
        let expectationDownloadImage = expectation(description: "get and download image")
        var result : Result<UIImage>?
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                let responseDict = response as? [String: Any]
                let imageArray = responseDict?["images"] as? [[String: Any]]
               
                let imageUrl = imageArray?[0]["url"] as? String
                if let imageUrl = imageUrl {
                    SnapchatAPI.downloadImage(imageUrl) { res in
                        expectationDownloadImage.fulfill()
                        result = res
                    }
                } else {
                    expectationDownloadImage.fulfill()
                }
            case .failure:
               XCTAssert(false)
               expectationDownloadImage.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10.0, handler: { _ in
            XCTAssertTrue(result?.value!.size.width == 512.0)
        })
    }
    
    func testErrorWithMessage() {
        let message = "testMessage"
        let error = NSError(domain: "com.alamofire",
                            code: -100,
                            userInfo: [NSLocalizedDescriptionKey: message])
        
        let alamofireError = SnapchatAPIConstants.Error.alamofireResultError(withMessage: "testMessage")
      
        
        let str: Result<Any> = Result.failure(error)
        XCTAssertTrue(str.description == alamofireError.description)
        XCTAssertTrue(str.debugDescription == alamofireError.debugDescription)
        XCTAssertTrue(str.isFailure == alamofireError.isFailure)
        
    }
    
    func testImageToData() {
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        let imageData = image?.toData(withCompressQuality: 0.8)
        
        XCTAssertEqual(imageData!, UIImageJPEGRepresentation(image!, 0.8))
    }
    
    func testGetImagesEndpoint() {
        XCTAssertEqual(SnapchatAPIConstants.URL.getImages(forUser: 11), "https://snappytestapp.herokuapp.com/images/get/11")
    }
}
