//
//  ClassTests.swift
//  SwiftRuntimeTests
//
//  Created by KIEU, HAI on 1/19/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import XCTest
#if os(tvOS)
    @testable import RuntimeTV
#else
    @testable import Runtime
#endif

class ClassTests: XCTestCase {
    var cls : AClass!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cls = AClass(type(of: self))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cls = nil
        super.tearDown()
    }
    
    func testCreateInstanceAtRuntimeStatic() {
        XCTAssertNoThrow(cls.createInstance())
    }
    
    func testCommons() {
        XCTAssertNoThrow(cls.runtimeClass)
        XCTAssertNoThrow(cls.baseClass)
        XCTAssertNoThrow(cls.protocols)
        XCTAssertNoThrow(cls.props)
    }
    
    func testClassProperties(){
        XCTAssert(cls.name.isEmpty == false)
        XCTAssert(cls.framework?.name.isEmpty == false)
        XCTAssert(cls.ivars.count > 0)
        XCTAssert(cls.methods.count > 0)
    }
}
