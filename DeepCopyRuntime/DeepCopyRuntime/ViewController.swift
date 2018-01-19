//
//  ViewController.swift
//  DeepCopyRuntime
//
//  Created by KIEU, HAI on 1/17/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit
import Foundation
import CoreFoundation



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let jackMa = People.JackMa
//        let _ = jackMa.deepCopy()
        Runtime.environment.listFrameworks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }


}



public protocol DeepCopy {
    
    func deepCopy() -> DeepCopy?
    
}

public extension DeepCopy where Self : AnyObject {
    func deepCopy() -> DeepCopy? {

        //Create runtime instance
        let runtimeClass = type(of: self)
        let runtimeInstance = class_createInstance(runtimeClass, class_getInstanceSize(runtimeClass))
        
        
        //Get a list of iVar
        var ivarCount : UInt32 = 0
        let ivarList = class_copyIvarList(runtimeClass, &ivarCount)
        defer { ivarList?.deallocate(capacity: Int(ivarCount))}//Prevent memory leak
        if let ivarList = ivarList {
            for i in 0..<Int(ivarCount) {
                let ivar = ivarList.advanced(by: i).pointee
                let ivarName = ivar_getName(ivar)
                let ivarNameStr = String.init(cString: ivarName!)
                print("ivarName >>> \(ivarNameStr)")
            }
        }
        
        var propCount : UInt32 = 0
        let propList = class_copyPropertyList(runtimeClass, &propCount)
        defer { propList?.deallocate(capacity: Int(propCount)) }
        if let propList = propList {
            for i in 0..<Int(propCount) {
                let prop = propList.advanced(by: i).pointee
                let propName = property_getName(prop)
                let propNameStr = String.init(cString: propName)
                print("propName >>> \(propNameStr)")
            }
        }
        
        var methodCount : UInt32 = 0
        let methodList = class_copyMethodList(runtimeClass, &methodCount)
        defer { methodList?.deallocate(capacity: Int(methodCount)) }
        if let methodList = methodList {
            for i in 0..<Int(methodCount) {
                let method = methodList.advanced(by: i).pointee
                let methodName = method_getName(method)
                let methodNameStr = NSStringFromSelector(methodName)
                
                var leng : Int = 0
                var char : CChar = 0
                let returnType = method_getReturnType(method, &char, leng)
                let returnTypeStr = String.init(cString: &char)
                print("methodName >>> \(methodNameStr) -> \(returnTypeStr)")
            }
        }
        
        var protocolCount : UInt32 = 0
        let protocolList = class_copyProtocolList(runtimeClass, &protocolCount)
        if let protocolList = protocolList {
            for i in 0..<Int(protocolCount) {
                let ptc = protocolList[i]
                let ptcName = protocol_getName(ptc)
                let ptcNameStr = String.init(cString: ptcName)
                print("protocolName >>> \(ptcNameStr)")
            }
        }
        
        //Runtime environment information---->
        if let layout = class_getIvarLayout(runtimeClass) {
            let layoutStr = String.init(cString: layout )
            print("layout >>> \(layoutStr)")
        }
        
        
        
        if let baby = runtimeInstance as? People {
            baby.name = "New instance"
            baby.age = 1
            baby.isMale = true
            print("dynamic instance >>> \(baby)")
        }
        
        
        return nil
    }
    
//    func stringClassFromString(_ className: String) -> AnyClass! {
//
//        /// get namespace
//        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;
//
//        /// get 'anyClass' with classname and namespace
//        let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!;
//
//        // return AnyClass!
//        return cls;
//    }
}


extension ViewController : DeepCopy {}


class People : DeepCopy {
 
    
    var age : Int!
    var isMale : Bool!
    var name : String!
    
    
    static var JackMa : People {
        let people = People()
        people.name = "Jackma"
        people.age = 20
        people.isMale = true
        return people
    }
    
}
extension UIApplication : DeepCopy {}

