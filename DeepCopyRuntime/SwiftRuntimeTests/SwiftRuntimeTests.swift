//
//  SwiftRuntimeTests.swift
//  SwiftRuntimeTests
//
//  Created by KIEU, HAI on 1/19/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import XCTest
@testable import SwiftRuntime

class SwiftRuntimeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRetrievingRuntimeFrameworks() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertNoThrow(Runtime.environment.frameworks)
        XCTAssertNoThrow(Runtime.environment.listFrameworks)
    }
    
    func testRetrievingRuntimeFrameworksPerformance() { self.measure { _ = Runtime.environment.frameworks } }
    
    
    func testRetrievingRuntimeClasses() {
        XCTAssertNoThrow(Runtime.environment.classes)
        XCTAssertNoThrow(Runtime.environment.listClassNames())
    }
    
    func testRetrievingRuntimeClassesPerformance() { self.measure { _ = Runtime.environment.classes } }
    
    func testRetrievingRuntimeProtocols() {
        XCTAssertNoThrow(Runtime.environment.protocols)
        XCTAssertNoThrow(Runtime.environment.listProtocols())
    }
    
    func testRetrievingRuntimeProtocolsPerformance() { self.measure { _ = Runtime.environment.protocols } }
    
}
