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
        
        if let image = image {
            SnapchatAPI.upload(image: image, completion: { response in
                switch response {
                case .failure(let error):
                    expectationUploadWithError.fulfill()
                    XCTAssertEqual(error.localizedDescription, "Stub is working!")
                default: ()
                }
            })
        } else {
            XCTAssert(false)
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
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
        
        if let image = image {
            SnapchatAPI.upload(image: image, completion: { response in
                switch response {
                case .success:
                    expectationWithNoError.fulfill()
                    let responseDict = response.value as? [String: String]
                    XCTAssertEqual(responseDict?["Success"], "Image uploaded correctly.")
                default: ()
                }
            })
        } else {
            XCTAssert(false)
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
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
        
        SnapchatAPI.getImages { (response) in
            switch response {
            case .success(let response):
                let responseDict = response as? [String: Any]
                XCTAssertTrue((responseDict?["images"] as? [[String: Any]])?.count == 2)
            case .failure:
                XCTAssert(false)
            }
            
            expectationGetAllImages.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
