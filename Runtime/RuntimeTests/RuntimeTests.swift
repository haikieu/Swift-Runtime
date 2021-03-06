//
//  RuntimeTests.swift
//  RuntimeTests
//
//  Created by KIEU, HAI on 1/29/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import XCTest
#if os(tvOS)
    @testable import RuntimeTV
#else
    @testable import Runtime
#endif



class RuntimeTests: XCTestCase {
    
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
        XCTAssertNoThrow(Runtime.environment.listFrameworks())
    }
    
    func testRetrievingRuntimeClasses() {
        XCTAssertNoThrow(Runtime.environment.classes)
        XCTAssertNoThrow(Runtime.environment.listClassNames())
    }
    
    func testRetrievingRuntimeProtocols() {
        XCTAssertNoThrow(Runtime.environment.protocols)
        XCTAssertNoThrow(Runtime.environment.listProtocols())
    }
    
    func testComparingProtocols() {
        XCTAssert(Runtime.environment.protocols.first != Runtime.environment.protocols.last)
    }
}
