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
    
    override func setUp() {
        super.setUp()
        // Pust setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
            case .success(_):
                XCTAssert(false)
            case .failure(_):
              XCTAssert(true)
            }
            
            expectationGetAllImages.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    
    
    func testAUploadImageWith400Error() {
        let exp = expectation(description: "upload image with 400 error")
        
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
                    exp.fulfill()
                    XCTAssertEqual(error.localizedDescription, "Stub is working!")
                default:
                break
                }
            })
        } else {
            XCTAssert(false)
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
