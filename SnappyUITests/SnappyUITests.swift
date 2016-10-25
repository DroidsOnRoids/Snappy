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
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTableViewImages() {
        XCUIDevice.shared().orientation = .portrait
        
        let scrollViewsQuery = XCUIApplication().scrollViews
        scrollViewsQuery.otherElements.scrollViews.otherElements.containing(.button, identifier:"TakePhotoButtonImage").element.swipeLeft()
        
        let table = scrollViewsQuery.children(matching: .table).element

        XCTAssertTrue(table.cells.count > 0)
     
        
    }
}
