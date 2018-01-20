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
    
    init(_ runtimeClass : AnyClass) { self.runtimeClass = runtimeClass }
    static func from(className: String) -> AClass? {
        guard let cls = NSClassFromString(className) else { return nil }
        return AClass(cls)
    }
    
    func createInstance() -> AnyObject {
        return class_createInstance(runtimeClass, class_getInstanceSize(runtimeClass)) as AnyObject
    }
    
    fileprivate(set) var runtimeClass : AnyClass
    
    fileprivate(set) lazy var baseClass : AClass? = {
        guard let cls = class_getSuperclass(runtimeClass) else { return nil}
        return AClass(cls)
    }()
    
    fileprivate(set) lazy var framework : AFramework? = {
        guard let image = class_getImageName(runtimeClass) else { return nil }
        return AFramework(image)
    }()
    
    fileprivate(set) lazy var name : String = { return String(cString: class_getName(runtimeClass))}()
    
    fileprivate(set) lazy var ivars : [Ivar] = {
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
    
    fileprivate(set) lazy var props : [AProperty] = {
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
    
    fileprivate(set) lazy var methods : [AMethod] = {
        var methods = [AMethod]()
        var methodCount : UInt32 = 0
        let methodList = class_copyMethodList(runtimeClass, &methodCount)
        defer { methodList?.deallocate(capacity: Int(methodCount)) }
        if let methodList = methodList {
            for i in 0..<Int(methodCount) {
                let method = AMethod(methodList.advanced(by: i).pointee)
                methods.append(method)
            }
        }
        return methods
    }()

    fileprivate(set) lazy var protocols  : [AProtocol] = {
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
    
    var objects : [AObject] {
        var objects = [AObject]()
        return objects
    }
    
}
class AObject{}
class AMethod {
    fileprivate(set) var method : Method
    fileprivate(set) lazy var selector : Selector = { return method_getName(method)}()
    fileprivate(set) lazy var name : String = { return NSStringFromSelector(selector)}()
    fileprivate(set) lazy var implementation : IMP = { return method_getImplementation(method)}()
    fileprivate(set) lazy var numberOfArgs : UInt32 = { return method_getNumberOfArguments(method)}()
    init(_ method : Method) {
        self.method = method
    }
    
    
}
class AProperty {
    fileprivate(set) var prop : objc_property_t
    fileprivate(set) lazy var name : String = { return String(cString: property_getName(prop)) }()
    init(_ prop : objc_property_t) {
        self.prop = prop
        
    }
}

class Arg {
    var index : String!
    var name : String!
    var type : Any!
}

class AIMP {}

class AIvar {
    fileprivate(set) var ivar : Ivar
    fileprivate(set) lazy var name : String = {
        let ivarName = ivar_getName(ivar)
        let ivarNameStr = String(cString: ivarName!)
        return ivarNameStr
    }()
    init(_ ivar : Ivar) {
        self.ivar = ivar
    }
}

public class AProtocol {
    fileprivate(set) var runtimeProtocol : Protocol
    fileprivate(set) lazy var name : String = { return String(cString: protocol_getName(runtimeProtocol))}()
    
    init(_ runtimeProtocol: Protocol) { self.runtimeProtocol = runtimeProtocol }
}

public class AFramework {
    fileprivate(set) var image : UnsafePointer<Int8>!
    fileprivate(set) lazy var path : String = { return String(utf8String: image) ?? "" }()
    fileprivate(set) lazy var url : URL! = { return URL(string: path)}()
    fileprivate(set) lazy var name : String = { return url.lastPathComponent }()
    init(_ image: UnsafePointer<Int8>) { self.image = image }
    
    fileprivate(set) lazy var classes : [AClass] = {
        var classes = [AClass]()
        var count : UInt32 = 0
        guard let list = objc_copyClassNamesForImage(image, &count) else { return classes }
        for i in 0..<Int(count) {
            let cls = list.advanced(by: 0).pointee
            guard let aCls = NSClassFromString(String(cString: cls)) else { continue }
            classes.append(AClass(aCls))
        }
        return classes
    }()
}

public final class Runtime {
    static let environment = Runtime()
    
    ///List of registered classes in runtime
    fileprivate(set) lazy var classes : [AClass] = {
        var classes = [AClass]()
        var clsCount : UInt32 = 0
        let clsList = objc_copyClassList(&clsCount)
        if let clsList = clsList {
            for i in 0..<Int(clsCount) { classes.append(AClass(clsList[i])) }
            return classes
        } else {
            return []
        }
    }()
    
    func listClassNames() {
        for (i, aClass) in classes.enumerated() {
            print("\(i). class \(aClass.name)")
        }
    }
    
    ///List of registered classes in runtime
    fileprivate(set) lazy var protocols : [AProtocol] = {
        var protocols = [AProtocol]()
        
        var pCount : UInt32 = 0
        let protocolList = objc_copyProtocolList(&pCount)
        print("Total runtime protocol \(pCount)")
        if let protocolList = protocolList {
            for i in 0..<Int(pCount) { protocols.append(AProtocol(protocolList[i])) }
            return protocols
        } else { return [] }
    }()
    
    func listProtocols() {
        for (i, aProtocol) in protocols.enumerated() {
            print("\(i). protocol \(aProtocol.name)")
        }
    }
  
    fileprivate(set) lazy var frameworks : [AFramework] = {
        var frameworks = [AFramework]()
        var fwCount : UInt32 = 0
        let fwsList = objc_copyImageNames(&fwCount)
        defer { fwsList.deallocate(capacity: Int(fwCount))}
        
        for i in 0..<Int(fwCount) {
            let fw = fwsList.advanced(by: i).pointee
            frameworks.append(AFramework(fw))
        }
        return frameworks
    }()
    
    func listFrameworks() {
        for (i, aFramework) in frameworks.enumerated() {
            print("\(i). Framework \(aFramework.url.lastPathComponent)")
            for (i, cls) in aFramework.classes.enumerated() {
                print("|-- \(i). Class \(cls.name)")
            }
        }
        
    }
    
}
