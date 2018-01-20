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

public class AFramework {
    public fileprivate(set) var image : UnsafePointer<Int8>!
    public fileprivate(set) lazy var path : String = { return String(utf8String: image) ?? "" }()
    public fileprivate(set) lazy var url : URL! = { return URL(string: path)}()
    public fileprivate(set) lazy var name : String = { return url.lastPathComponent }()
    public init(_ image: UnsafePointer<Int8>) { self.image = image }
    
    public fileprivate(set) lazy var classes : [AClass] = {
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
    
    public func dyload() -> Bool {
        
        guard dlopen_preflight(image) else {
            //https://www.unix.com/man-page/osx/3/dlopen_preflight/
            //dlopen_preflight() returns true on if the mach-o file is compatible.  If the file is not
            //compatible, it returns false and sets an error string that can be examined with dlerror().
            if let error = dlerror() {
                let errorStr = String.init(utf8String: error)
                print("error")
            }
            return false
        }
        
        guard let loadedFW = dlopen(image, RTLD_NOW) else {
            //Cannot load
            return false
        }
        defer { dlclose(loadedFW)}
        let function = dlsym(loadedFW, "")
        
        return true
        
    }
}
