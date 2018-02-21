/*
 MIT License
 
 Copyright (c) 2018 Hai Kieu
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

public class AClass {
    
    public init(_ runtimeClass : AnyClass) { self.runtimeClass = runtimeClass }
    open class func from(className: String) -> AClass? {
        guard let cls = NSClassFromString(className) else { return nil }
        return AClass(cls)
    }
    
    public func createInstance() -> AnyObject {
        return class_createInstance(runtimeClass, class_getInstanceSize(runtimeClass)) as AnyObject
    }
    
    
    open static func instantiate(from cls:AnyClass) -> AnyObject {
        return class_createInstance(cls, class_getInstanceSize(cls)) as AnyObject
    }
    
    public fileprivate(set) var runtimeClass : AnyClass
    
    public fileprivate(set) lazy var baseClass : AClass? = {
        guard let cls = class_getSuperclass(runtimeClass) else { return nil}
        return AClass(cls)
    }()
    
    public fileprivate(set) lazy var framework : AFramework? = {
        guard let image = class_getImageName(runtimeClass) else { return nil }
        return AFramework(image)
    }()
    
    public fileprivate(set) lazy var name : String = { return String(cString: class_getName(runtimeClass))}()
    
    public fileprivate(set) lazy var ivars : [Ivar] = {
        var ivars = [Ivar]()
        //Get a list of iVar
        var ivarCount : UInt32 = 0
        let ivarList = class_copyIvarList(runtimeClass, &ivarCount)
        defer { ivarList?.deallocate(capacity: Int(ivarCount))}//Prevent memory leak
        if let ivarList = ivarList {
            for i in 0..<Int(ivarCount) {
                let ivar = ivarList.advanced(by: i).pointee
                ivars.append(ivar)
            }
        }
        return ivars
    }()
    
    public fileprivate(set) lazy var props : [AProperty] = {
        var props = [AProperty]()
        var propCount : UInt32 = 0
        let propList = class_copyPropertyList(runtimeClass, &propCount)
        defer { propList?.deallocate(capacity: Int(propCount)) }
        if let propList = propList {
            for i in 0..<Int(propCount) {
                let prop = AProperty(propList.advanced(by: i).pointee)
                props.append(prop)
            }
        }
        return props
    }()
    
    public fileprivate(set) lazy var methods : [AMethod] = {
        var methods = [AMethod]()
        var methodCount : UInt32 = 0
        let methodList = class_copyMethodList(runtimeClass, &methodCount) //This does not work for Swift Object.
        defer { methodList?.deallocate(capacity: Int(methodCount)) }
        if let methodList = methodList {
            for i in 0..<Int(methodCount) {
                let method = AMethod(methodList.advanced(by: i).pointee)
                methods.append(method)
            }
        }
        return methods
    }()
    
    public fileprivate(set) lazy var protocols  : [AProtocol] = {
        var procotols = [AProtocol]()
        var protocolCount : UInt32 = 0
        let protocolList = class_copyProtocolList(runtimeClass, &protocolCount)
        if let protocolList = protocolList {
            for i in 0..<Int(protocolCount) {
                let ptc = AProtocol(protocolList[i])
                procotols.append(ptc)
            }
        }
        return procotols
    }()
    
    @available(*, unavailable, message: "This is not available")
    public var objects : [AObject] {
        var objects = [AObject]()
        return objects
    }
}

public class AObject{
    
}
public class AMethod {
    public fileprivate(set) var method : Method
    public fileprivate(set) lazy var selector : ASelector = { return ASelector(method_getName(method))}()
    public fileprivate(set) lazy var name : String = { return selector.name}()
    public fileprivate(set) lazy var isValid : Bool = { return selector.isValid}()
    public fileprivate(set) lazy var implementation : IMP = { return method_getImplementation(method)}()
    
    public fileprivate(set) lazy var arguments : [String] = {
        var arguments = [String]()
        let count = method_getNumberOfArguments(method)
        for i in 0..<count {
            guard let t = method_copyArgumentType(method, i), let text = String(utf8String: t) else { continue}
            arguments.append(text)
        }
        return arguments
    }()
    
    public fileprivate(set) lazy var returnType : String = {
        return String(utf8String: method_copyReturnType(method)) ?? ""
    }()
    public fileprivate(set) lazy var typeEncoding : String = {
        guard let encoding = method_getTypeEncoding(method) else { return "" }
        return String(utf8String: encoding) ?? ""
    }()
    public init(_ method : Method) {
        self.method = method
    }
}

public class AMethodDescription {
    public fileprivate(set) var aDescription : objc_method_description
    public fileprivate(set) lazy var name : Selector? = { return aDescription.name }()
    public fileprivate(set) lazy var types : String? = {
        guard let t = aDescription.types else { return nil }
        return String.init(utf8String: t)
    }()
    
    fileprivate init(_ aDescription : objc_method_description) {
        self.aDescription = aDescription
    }
}

public class ASelector : Equatable {
    
    public fileprivate(set) var sel : Selector
    public fileprivate(set) lazy var name : String = { return String(cString: sel_getName(sel)) }()
    public fileprivate(set) lazy var isValid : Bool = { return sel_isMapped(sel) }()
    public init(_ sel : Selector) { self.sel = sel }
    public init(_ uid : UnsafePointer<Int8>) { self.sel = sel_getUid(uid)}
    public static func ==(lhs: ASelector, rhs: ASelector) -> Bool { return sel_isEqual(lhs.sel, rhs.sel) }
    
}

public class AProperty {
    public fileprivate(set) var prop : objc_property_t
    public fileprivate(set) lazy var name : String = { return String(cString: property_getName(prop)) }()
    public fileprivate(set) lazy var attributesStr : String? = {
        guard let attrs = property_getAttributes(prop) else { return nil}
        return String(cString: attrs)
    }()
    public fileprivate(set) lazy var attributes : [Attribute] = {
        var attributes = [Attribute]()
        var count : UInt32 = 0
        let list = property_copyAttributeList(prop, &count)
        
        defer { list?.deallocate(capacity: Int(count))}
        for i in 0..<Int(count) {
            guard let att = list?.advanced(by: 0).pointee else { continue }
            attributes.append(Attribute(att))
        }
        return attributes
    }()
    
    fileprivate init(_ prop : objc_property_t) { self.prop = prop }
}

public class Attribute {
    public fileprivate(set) var att : objc_property_attribute_t
    public fileprivate(set) lazy var name : String = { return String(utf8String:att.name) ?? "" }()
    public fileprivate(set) lazy var value : String = { return String(utf8String:att.value) ?? "" }()
    fileprivate init(_ att: objc_property_attribute_t) { self.att = att}
}

public class AIMP {
    public fileprivate(set) var imp : IMP
    public fileprivate(set) lazy var block : Any? = { return imp_getBlock(imp) }()
    public init(_ imp: IMP) {
        self.imp = imp
    }
    public init(_ block: Any) {
        self.imp = imp_implementationWithBlock(block)
    }
}

public class AIvar {
    public fileprivate(set) var ivar : Ivar
    public fileprivate(set) lazy var name : String = {
        let ivarName = ivar_getName(ivar)
        let ivarNameStr = String(cString: ivarName!)
        return ivarNameStr
    }()
    fileprivate init(_ ivar : Ivar) {
        self.ivar = ivar
    }
}

public class AProtocol : Equatable{
    public static func ==(lhs: AProtocol, rhs: AProtocol) -> Bool {
        return protocol_isEqual(lhs.runtimeProtocol, rhs.runtimeProtocol)
    }
    
    public fileprivate(set) var runtimeProtocol : Protocol
    public fileprivate(set) lazy var name : String = { return String(cString: protocol_getName(runtimeProtocol))}()
    
    public init(_ runtimeProtocol: Protocol) { self.runtimeProtocol = runtimeProtocol }
}
