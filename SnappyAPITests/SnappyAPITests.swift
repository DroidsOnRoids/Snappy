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

class SnappyAPITests: XCTestCase {
    
    func testGetAllImages() {
        let expectationGetAllImages = self.expectation(description: "getting all images")
        
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                let responseDict = response as? [String: Any]
                let imageArray = responseDict?["images"] as? [[String: Any]]
                XCTAssertTrue(imageArray!.count > 0)
            case .failure(_):
                XCTAssert(false)
            }
            expectationGetAllImages.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testAUploadImage() {
        let expectation = self.expectation(description: "upload image")
        
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        
        if let image = image {
            SnapchatAPI.upload(image: image, completion: { (response) in
                switch response {
                case .success(_):
                    XCTAssert((response.value != nil))
                case .failure(_):
                    XCTAssert(false)
                }
                expectation.fulfill()
            })
        } else {
            XCTAssert(false)
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testDownloadImage() {
        let expectation = self.expectation(description: "get and download image")
        
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                let responseDict = response as? [String: Any]
                let imageArray = responseDict?["images"] as? [[String: Any]]
               
                let imageUrl = imageArray?[0]["url"] as? String
                if let imageUrl = imageUrl {
                    SnapchatAPI.downloadImage(imageUrl) { result in
                        XCTAssertTrue(result.value!.size.width == 512.0)
                        expectation.fulfill()
                    }
                }
            case .failure(_):
               XCTAssert(false)
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
