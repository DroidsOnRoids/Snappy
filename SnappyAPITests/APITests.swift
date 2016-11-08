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
       weak var expectationUploadForSpecificUser = expectation(description: "upload image for specific user")
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        var result: [String: String]?
        
        if let image = image {
            SnapchatAPI.upload(image: image, toUser: 11, completion: { response in
                switch response {
                case .success(let response):
                    result = response as? [String: String]
                case .failure: ()
                }
              
                expectationUploadForSpecificUser?.fulfill()
                expectationUploadForSpecificUser = nil
            })
        }
        
        waitForExpectations(timeout: 5.0, handler: { error in
            XCTAssert(result?["error"] == nil)
        })
    }
    
    func testGetAllImages() {
        weak var expectationGetAllImages = expectation(description: "getting all images")
        var imageArray : [Any]?
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                let responseDict = response as? [String: Any]
                imageArray = responseDict?["images"] as? [[String: Any]]
            case .failure: ()
            }
            
            expectationGetAllImages?.fulfill()
            expectationGetAllImages = nil
        }
        
        waitForExpectations(timeout: 5.0, handler: { error in
            if let imageArray = imageArray {
                XCTAssertTrue(imageArray.count > 0)
            } else {
                XCTFail()
            }
        })
    }
    
    func testAUploadImage() {
        weak var expectationUploadImage = expectation(description: "upload image")
        
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        var result : Result<Any>?
       
        if let image = image {
            SnapchatAPI.upload(image: image, completion: { response in
                switch response {
                case .success:
                    result = response
                case .failure:()
                }
                
                expectationUploadImage?.fulfill()
                expectationUploadImage = nil
                
            })
        }

        waitForExpectations(timeout: 5.0, handler: { error in
             XCTAssert((result?.value != nil))
        })
    }
    
    func testGetImageAndDownloadImage() {
        weak var expectationDownloadImage = expectation(description: "get and download image")
        weak var expectationGetImage = expectation(description: "get image")
        var result : Result<UIImage>?
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                let responseDict = response as? [String: Any]
                let imageArray = responseDict?["images"] as? [[String: Any]]
               
                let imageUrl = imageArray?[0]["url"] as? String
                if let imageUrl = imageUrl {
                    SnapchatAPI.downloadImage(imageUrl) { res in
                        expectationDownloadImage?.fulfill()
                        expectationGetImage?.fulfill()
                        expectationGetImage = nil
                        expectationDownloadImage = nil
                        result = res
                    }
                } else {
                    XCTFail()
                    expectationGetImage?.fulfill()
                    expectationGetImage = nil
                }
            case .failure:
               XCTFail()
               expectationGetImage?.fulfill()
               expectationGetImage = nil
            }
        }
        
        waitForExpectations(timeout: 10.0, handler: { _ in
            XCTAssertTrue(result?.value?.size.width == 512.0)
        })
    }
    
    func getAllImages(completion: @escaping ([String: Any]?) -> () ) {
        var imageArray : [Any]?
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                let responseDict = response as? [String: Any]
                imageArray = responseDict?["images"] as? [[String: Any]]
            case .failure: ()
            }
            
            completion(imageArray?.first as? [String: Any])
         }
    }
    
    func testRemoveImageWithoutSpecificUser() {
        weak var expectationUploadImage = expectation(description: "upload image")
        
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        var result : [String: String]?
        getAllImages { images in
            if let imageFileName = images?["file_name"] as? String {
                if let image = image {
                    SnapchatAPI.upload(image: image, completion: { response in
                        switch response {
                        case .success:
                            SnapchatAPI.removeImage(forUser: nil, fileName: imageFileName, completionHandler: { removeResult in
                                result = removeResult.value as? [String: String]
                                expectationUploadImage?.fulfill()
                                expectationUploadImage = nil
                            })
                        case .failure:()
                        }
                    })
                }
            } else {
                XCTFail("there is no images on server")
            }
        }
    
        waitForExpectations(timeout: 5.0, handler: { error in
            XCTAssert(result?["error"] == nil)
        })
    }
    
    func testRemoveImageWithSpecificUser() {
        weak var expectationUploadImage = expectation(description: "upload image")
        
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        var result : [String: String]?
        getAllImages { images in
            if let imageFileName = images?["file_name"] as? String {
                if let image = image {
                    SnapchatAPI.upload(image: image, completion: { response in
                        switch response {
                        case .success:
                            SnapchatAPI.removeImage(forUser: images?["from_userId"] as? Int, fileName: imageFileName, completionHandler: { removeResult in
                                result = removeResult.value as? [String: String]
                                expectationUploadImage?.fulfill()
                                expectationUploadImage = nil
                            })
                        case .failure:()
                        }
                    })
                }
            } else {
                XCTFail("there is no images on server")
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: { error in
            XCTAssert(result?["error"] == nil)
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
   
    func testImageToDataWithDefault08Value() {
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        let imageData = image?.toData()
        
        XCTAssertEqual(imageData!, UIImageJPEGRepresentation(image!, 0.8))
    }
    
    func testGetImagesEndpoint() {
        XCTAssertEqual(SnapchatAPIConstants.URL.getImages(forUser: 11), "https://snappytestapp.herokuapp.com/images/get/11")
    }
}
