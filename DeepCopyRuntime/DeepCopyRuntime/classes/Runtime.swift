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
    
    fileprivate(set) var runtimeClass : AnyClass
    fileprivate(set) lazy var name : String = { return String.init(cString: class_getName(runtimeClass))}()
    
    init(_ runtimeClass : AnyClass) { self.runtimeClass = runtimeClass }
}

public class AProtocol {
    fileprivate(set) var runtimeProtocol : Protocol
    fileprivate(set) lazy var name : String = { return String.init(cString: protocol_getName(runtimeProtocol))}()
    
    init(_ runtimeProtocol: Protocol) { self.runtimeProtocol = runtimeProtocol }
}

public class AFramework {
    fileprivate(set) var image : UnsafePointer<Int8>!
    fileprivate(set) lazy var path : String = { return String(utf8String: image) ?? "" }()
    fileprivate(set) lazy var url : URL! = { return URL.init(string: path)}()
    init(_ image: UnsafePointer<Int8>) { self.image = image }
    
    fileprivate(set) lazy var classes : [AClass] = {
        var classes = [AClass]()
        var count : UInt32 = 0
        guard let list = objc_copyClassNamesForImage(image, &count) else { return classes }
        for i in 0..<Int(count) {
            let cls = list.advanced(by: 0).pointee
            guard let aCls = NSClassFromString(String.init(cString: cls)) else { continue }
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

        //Runtime environment information<-----
//    }
    
}