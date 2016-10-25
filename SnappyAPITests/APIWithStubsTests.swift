//
//  APIWithStubsTests.swift
//  Snappy
//
//  Created by Pawel Chmiel on 21.10.2016.
//  Copyright © 2016 Droids On Roids. All rights reserved.
//

import XCTest
import Alamofire
import AlamofireImage
import OHHTTPStubs

@testable import Snappy

class APIWithStubsTests: XCTestCase {
    
   
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testGetAllImagesNotValidJSON() {
        
        let expectationGetAllImages = expectation(description: "getting all images with not valid json")
        
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return true
        }) { (request) -> OHHTTPStubsResponse in
            let stubData = "NOT VALID JSON".data(using: .utf8)
            return OHHTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success:
                XCTAssert(false)
            case .failure:
                XCTAssert(true)
            }
            
            expectationGetAllImages.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testAUploadImageWith400Error() {
        let expectationUploadWithError = expectation(description: "upload image with 400 error")
        
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return true
        }) { (request) -> OHHTTPStubsResponse in
            let stubData = "{\"error\": \"Stub is working!\"}".data(using: .utf8)
            return OHHTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        var errorResponse: Error?
        if let image = image {
            SnapchatAPI.upload(image: image, completion: { response in
                switch response {
                case .failure(let error):
                    expectationUploadWithError.fulfill()
                    errorResponse = error
                default: ()
                }
            })
        }
        
        waitForExpectations(timeout: 5.0, handler: { _ in
             XCTAssertEqual(errorResponse?.localizedDescription, "Stub is working!")
        })
    }
    
    func testAUploadImageWithNoError() {
        let expectationWithNoError = expectation(description: "upload image with no error")
        
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return true
        }) { (request) -> OHHTTPStubsResponse in
            let stubData = "{\"Success\": \"Image uploaded correctly.\"}".data(using: .utf8)
            return OHHTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(contentsOfFile: bundle.path(forResource: "thunder", ofType: "png")!)
        var responseDict: [String: String]?
        
        if let image = image {
            SnapchatAPI.upload(image: image, completion: { response in
                switch response {
                case .success:
                    responseDict = response.value as? [String: String]
                default: ()
                }
                
                expectationWithNoError.fulfill()
            })
        }
        
        waitForExpectations(timeout: 5.0, handler: { _ in
            if let message = responseDict?["Success"] {
                XCTAssertEqual(message, "Image uploaded correctly.")
            } else {
                XCTAssert(false)
            }
        })
    }
    
    func testDownloadAllImagesFromStub() {
        let expectationGetAllImages = expectation(description: "download from stub")
        
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return true
        }) { (request) -> OHHTTPStubsResponse in
            let bundle = Bundle(for: self.classForCoder)
            let stubData = try! Data(contentsOf: URL(fileURLWithPath: bundle.path(forResource: "sampleData", ofType: "json", inDirectory: nil)!))
            return OHHTTPStubsResponse(data: stubData, statusCode: 200, headers: nil)
        }
        
        var responseDict: [String: Any]?
        
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                 responseDict = response as? [String: Any]
            case .failure: ()
            }
            
            expectationGetAllImages.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: { _ in
            if let images = responseDict?["images"] as? [AnyObject] {
               XCTAssertTrue(images.count == 2)
            } else {
                XCTAssert(false)
            }
            
        })
    }
}
