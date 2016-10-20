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
        let expectation = self.expectation(description: "upload image for specific user")
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        var result : Result<Any>?
        
        if let image = image {
            SnapchatAPI.upload(image: image, toUser: 11, completion: { response in
                switch response {
                case .success(_):
                    result = response
                case .failure(_):
                    XCTAssert(false)
                }
                expectation.fulfill()
            })
        } else {
            XCTAssert(false)
        }
        
        waitForExpectations(timeout: 5.0, handler: { error in
            XCTAssert((result?.value != nil))
        })
    }
    
    func testGetAllImages() {
        let expectationGetAllImages = self.expectation(description: "getting all images")
        var imageArray : [Any]?
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                let responseDict = response as? [String: Any]
                imageArray = responseDict?["images"] as? [[String: Any]]
            case .failure(_):
                XCTAssert(false)
            }
            
            expectationGetAllImages.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: { error in
            XCTAssertTrue(imageArray!.count > 0)
        })
    }
    
    func testAUploadImage() {
        let expectation = self.expectation(description: "upload image")
        
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        var result : Result<Any>?
       
        if let image = image {
            SnapchatAPI.upload(image: image, completion: { response in
                switch response {
                case .success(_):
                    result = response
                case .failure(_):
                    XCTAssert(false)
                }
                expectation.fulfill()
            })
        } else {
            XCTAssert(false)
        }

        waitForExpectations(timeout: 5.0, handler: { error in
             XCTAssert((result?.value != nil))
        })
    }
    
    func testDownloadImage() {
        let expectation = self.expectation(description: "get and download image")
        var result : Result<UIImage>?
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                let responseDict = response as? [String: Any]
                let imageArray = responseDict?["images"] as? [[String: Any]]
               
                let imageUrl = imageArray?[0]["url"] as? String
                if let imageUrl = imageUrl {
                    SnapchatAPI.downloadImage(imageUrl) { res in
                        expectation.fulfill()
                        result = res
                    }
                }
            case .failure(_):
               XCTAssert(false)
               expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10.0, handler: { error in
            print("error \(error)")
            XCTAssertTrue(result?.value!.size.width == 512.0)
        })
    }
}