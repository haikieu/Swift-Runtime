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
import SwiftRuntime

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let jackMa = People.JackMa
        let _ = jackMa.deepCopy()
//        Runtime.environment.listFrameworks()
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
        let aClass = AClass(type(of: self))
        let runtimeInstance = aClass.createInstance()
        
        print("\(aClass.baseClass?.framework?.name ?? "no framework")")
        
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

