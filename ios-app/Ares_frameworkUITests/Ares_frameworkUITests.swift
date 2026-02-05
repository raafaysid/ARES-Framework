//
//  Ares_frameworkUITests.swift
//  Ares_frameworkUITests
//
//  Created by Raafay Siddiqui on 1/22/26.
//

import XCTest

final class Ares_frameworkUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testConnectionStatusIsVisible() throws {
        // launch the app
        let app = XCUIApplication()
        app.launch()

        // look for the text "Status"
        let statusRow = app.otherElements["StatusRow"]
        
        // assert that the label actually exists on the screen
        XCTAssertTrue(statusRow.waitForExistence(timeout: 10), "The Status row should be visible on launch.")
        // use a timeout to give the app a second to load

    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
