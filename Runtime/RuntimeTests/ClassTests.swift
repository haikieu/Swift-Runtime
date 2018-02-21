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

protocol MockProtocol : class {
    
}

class NSMockClass : NSObject{
    
    weak var delegate : MockProtocol?
    
    var varStr1 : String
    var varStr2 : String!
    var varStr3 : String?
    
    override init() {
        
        varStr1 = "something"
        
        super.init()
    }
    
    func instaceMethod1() {
        
    }
    
    func instanceMethod2() -> Bool {
        return false
    }
    
    static func staticMethod() {
    
    }
}

class ClassTests: XCTestCase {
    var cls : AClass!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        #if os(tvOS)
            cls = AClass.from(className: "RuntimeTVTests.NSMockClass")
        #else
            cls = AClass.from(className: "RuntimeTests.NSMockClass")
        #endif
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cls = nil
        super.tearDown()
    }
    
    func testCreateInstanceAtRuntimeStatic() {
        XCTAssertNotNil(cls.createInstance())
    }
    
    func testInvalidClassName() {
        XCTAssertNil(AClass.from(className: "InValidClassName"))
    }
    
    func testCommons() {
        XCTAssertNotNil(cls.runtimeClass)
        XCTAssertNotNil(cls.baseClass)
        XCTAssertNotNil(cls.protocols)
        XCTAssertNotNil(cls.props)
    }
    
    func testClassProperties(){
        XCTAssert(cls.name.isEmpty == false)
        XCTAssert(cls.framework?.name.isEmpty == false)
        XCTAssert(cls.ivars.count > 0)
        XCTAssert(cls.methods.count > 0)
    }
}
