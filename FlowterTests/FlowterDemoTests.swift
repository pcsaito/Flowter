//
//  FlowterTests.swift
//  FlowterTests
//
//  Created by Paulo Cesar Saito on 05/06/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import KIF
import XCTest
@testable import FlowterDemo

class FlowterDemoTests: KIFTestCase {    
    func startFlow() -> UIView {
        tester().tapView(withAccessibilityLabel: "startFlowButton")
        
        return tester().waitForView(withAccessibilityLabel: "Flow Start")
    }

    func closeFlow() -> UIView {
        tester().tapView(withAccessibilityLabel: "closeButton")
        
        return tester().waitForView(withAccessibilityLabel: "HomeViewController")
    }

    func fowardFlow() -> UIView {
        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "1st Step")

        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "2nd Step")

        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "3rd Step")

        tester().tapView(withAccessibilityLabel: "nextButton")
       
        return tester().waitForView(withAccessibilityLabel: "Flow Ending")
    }

    func backFlow() -> UIView {
        tester().tapView(withAccessibilityLabel: "backButton")
        tester().waitForView(withAccessibilityLabel: "3rd Step")

        tester().tapView(withAccessibilityLabel: "backButton")
        tester().waitForView(withAccessibilityLabel: "2nd Step")

        tester().tapView(withAccessibilityLabel: "backButton")
        tester().waitForView(withAccessibilityLabel: "1st Step")

        tester().tapView(withAccessibilityLabel: "backButton")

        return tester().waitForView(withAccessibilityLabel: "Flow Start")
    }

    func testOpenFlow() {
        XCTAssertNotNil(startFlow())
        XCTAssertNotNil(closeFlow())
    }

    func testFowardFlow() {
        XCTAssertNotNil(startFlow())
        XCTAssertNotNil(fowardFlow())
        XCTAssertNotNil(closeFlow())
    }

    func testBackFlow() {
        XCTAssertNotNil(startFlow())
        XCTAssertNotNil(fowardFlow())
        XCTAssertNotNil(backFlow())
        XCTAssertNotNil(closeFlow())
    }

    func testCompleteFlow() {
        XCTAssertNotNil(startFlow())
        XCTAssertNotNil(fowardFlow())

        tester().tapView(withAccessibilityLabel: "nextButton")
        
        let view = tester().waitForView(withAccessibilityLabel: "HomeViewController")
        XCTAssertNotNil(view)
    }

    func testCloseOnMidFlow() {
        XCTAssertNotNil(startFlow())

        tester().tapView(withAccessibilityLabel: "nextButton")
        tester().waitForView(withAccessibilityLabel: "1st Step")

        tester().tapView(withAccessibilityLabel: "nextButton")
        
        let view = tester().waitForView(withAccessibilityLabel: "2nd Step")
        XCTAssertNotNil(view)
        
        XCTAssertNotNil(closeFlow())
    }

    func testStressFlow() {
        XCTAssertNotNil(startFlow())

        for _ in 0..<2 {
            XCTAssertNotNil(fowardFlow())
            XCTAssertNotNil(backFlow())
        }
    
        XCTAssertNotNil(closeFlow())
    }    
}
