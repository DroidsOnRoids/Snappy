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
}
