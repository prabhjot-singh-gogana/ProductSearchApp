//
//  ProductSearchAppUITests.swift
//  ProductSearchAppUITests
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import XCTest

final class ProductSearchAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testProductSearchScreenLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Products"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.searchFields["Search products"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
