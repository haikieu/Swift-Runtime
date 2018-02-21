//
//  FrameworkTests.swift
//  Runtime
//
//  Created by KIEU, HAI on 2/21/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import XCTest
#if os(tvOS)
    @testable import RuntimeTV
#else
    @testable import Runtime
#endif

class FrameworkTests: XCTestCase {
    
    var framework : AFramework!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        framework = Runtime.environment.frameworks.first
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFramework() {
        XCTAssertNotNil(framework.image)
        XCTAssertFalse(framework.path.isEmpty)
        XCTAssertFalse(framework.name.isEmpty)
        XCTAssertNotNil(framework.url)
        XCTAssert(framework.classes.count > 0)
    }
    
    func testDyLoad() {
        var boolean = self.framework.dyload()
        XCTAssert(boolean == true)
    }
    
}
