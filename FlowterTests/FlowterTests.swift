//
//  FlowterTests.swift
//  FlowterTests
//
//  Created by Paulo Cesar Saito on 05/06/18.
//  Copyright © 2018 Zazcar. All rights reserved.
//

import XCTest
@testable import FlowterDemo

class FlowterTests: KIFTestCase {
    func startFlow() {
        tester().tapView(withAccessibilityLabel: "startFlowButton")
        tester().waitForView(withAccessibilityLabel: "Flow Start")
    }

    func closeFlow() {
        tester().tapView(withAccessibilityLabel: "closeButton")
        tester().waitForView(withAccessibilityLabel: "InitialViewController")
    }

    func fowardFlow() {
        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "1st Step")

        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "2nd Step")

        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "3rd Step")

        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "Flow Ending")
    }

    func backFlow() {
        tester().tapView(withAccessibilityLabel: "backButton")
        tester().waitForView(withAccessibilityLabel: "3rd Step")

        tester().tapView(withAccessibilityLabel: "backButton")
        tester().waitForView(withAccessibilityLabel: "2nd Step")

        tester().tapView(withAccessibilityLabel: "backButton")
        tester().waitForView(withAccessibilityLabel: "1st Step")

        tester().tapView(withAccessibilityLabel: "backButton")
        tester().waitForView(withAccessibilityLabel: "Flow Start")
    }

    func testOpenFlow() {
        startFlow()
        closeFlow()
    }

    func testFowardFlow() {
        startFlow()
        fowardFlow()
        closeFlow()
    }

    func testBackFlow() {
        startFlow()
        fowardFlow()
        backFlow()
        closeFlow()
    }

    func testCompleteFlow() {
        startFlow()
        fowardFlow()

        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "InitialViewController")
    }

    func testCloseOnMidFlow() {
        startFlow()

        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "1st Step")

        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "2nd Step")

        closeFlow()
    }

    func testStressFlow() {
        startFlow()

        for _ in 0...5 {
            fowardFlow()
            backFlow()
        }
        closeFlow()
    }
}
