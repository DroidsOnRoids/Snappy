//
//  SnappyUITests.swift
//  SnappyUITests
//
//  Created by Pawel Chmiel on 24.10.2016.
//  Copyright © 2016 Droids On Roids. All rights reserved.
//

import XCTest

class SnappyUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testTableViewImages() {
        XCUIDevice.shared().orientation = .portrait
        
        let scrollViewsQuery = XCUIApplication().scrollViews
        scrollViewsQuery.otherElements.scrollViews.otherElements.containing(.button, identifier:"TakePhotoButtonImage").element.swipeLeft()
        let table = scrollViewsQuery.children(matching: .table).element

        XCTAssertTrue(table.cells.count > 0)
    }
    
    func testNavigation() {
        XCUIDevice.shared().orientation = .portrait
    
        let app = XCUIApplication()
        let takephotobuttonimageElement = app.scrollViews.otherElements.scrollViews.otherElements.containing(.button, identifier:"TakePhotoButtonImage").element
        takephotobuttonimageElement.swipeLeft()
        
        let scrollView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .scrollView).element
        scrollView.swipeRight()
    }
    
}
