//
//  Swizzler.swift
//  Swizzler
//
//  Created by xiaoyuan on 2021/7/29.
//

import Foundation

public struct Swizzle: CustomStringConvertible {
    public let original: Item
    public var new: Item
    
    init(original: Item,
         new: Item) {
        self.new = new
        self.original = original
    }
    
    public var description: String {
        var retValue = "Swizzle on \(String(describing: self.original.aClass))::\(NSStringFromSelector(original.selector)) ["
        retValue += "\t\(String(describing: new.aClass)) : \(String(describing: new.selector))\n"
        return retValue + "]"
    }
    
    public struct Item {
        public let aClass: AnyClass
        public let selector: Selector
        public let methodImp: IMP
        public let method: Method
        
        init(aClass: AnyClass, selector: Selector) throws {
            guard let method = class_getInstanceMethod(aClass, selector) else {
                throw SwizzleError.notFoundMethod(aClass: aClass, selector: selector)
            }
            self.aClass = aClass
            self.selector = selector
            self.method = method
            self.methodImp = method_getImplementation(method)
        }
        
        /// 恢复方法实现
        public func reset() {
            guard let method = class_getInstanceMethod(aClass, selector) else {
                return
            }
            
            guard let swizzle = Swizzle.getSwizzle(with: method) else {
                return
            }
            /// 恢复原方法的调用，必须用`swizzle.original`去还原
            method_setImplementation(swizzle.original.method, swizzle.original.methodImp)
            Swizzle.removeSwizzle(for: method)
        }
        
        /// 替换方法实现
        public func replace(with new: Swizzle.Item) {
            
            let method = self.method
            var temSwizzle: Swizzle
            if let swizzle = Swizzle.getSwizzle(with: method) {
                temSwizzle = swizzle
            }
            else {
                temSwizzle = Swizzle(original: self, new: new)
            }
            
            let didAddMethod = class_addMethod(new.aClass,
                                               self.selector,
                                               new.methodImp,
                                               method_getTypeEncoding(new.method))
            if !didAddMethod {
                method_setImplementation(method, new.methodImp)
            }
            Swizzle.setSwizzle(temSwizzle, for: method)
        }
        
        public func replace(with selector: Selector) throws {
            
            let new = try Item(aClass: self.aClass, selector: selector)
            self.replace(with: new)
        }
        
        /// 调用原方法实现，只能响应没有参数的方法，有参数的由于类型不确定，在调用时传递的都是空，所以需要自己重写
        func callFunction(withInsatnce ins: NSObject) {
            guard let method = class_getInstanceMethod(aClass, selector),
                  let swizzler = Swizzle.getSwizzle(with: method) else {
                return
            }
            typealias CFunction = @convention(c) (AnyObject, Selector) -> Void
            let curriedImplementation = unsafeBitCast(swizzler.original.methodImp, to: CFunction.self)
            curriedImplementation(ins, selector)
        }
        
    }
}

enum SwizzleError: Error, CustomStringConvertible {
    
    /// 未找到方法
    case notFoundMethod(aClass: AnyClass, selector: Selector)
    
    var description: String {
        switch self {
        case let .notFoundMethod(aClass, selector):
            return "Swizzling error: Cannot find method for "
                + "\(NSStringFromSelector(selector)) on \(NSStringFromClass(aClass))"
        }
    }
}

extension Swizzle.Item: Equatable {
    public static func == (lhs: Swizzle.Item, rhs: Swizzle.Item) -> Bool {
        lhs.aClass == rhs.aClass && lhs.selector == rhs.selector
    }
}

extension Swizzle {
    public static var swizzles = [Method: Swizzle]()
    
    public static func getSwizzle(with method: Method) -> Swizzle? {
        return swizzles[method]
    }
    
    fileprivate static func removeSwizzle(for method: Method) {
        swizzles.removeValue(forKey: method)
    }
    
    fileprivate static func setSwizzle(_ swizzle: Swizzle, for method: Method) {
        swizzles[method] = swizzle
    }
    
    public static func swizzle(selector: Selector,
                               newSelector: Selector,
                               aClass: AnyClass,
                               newClass: AnyClass? = nil) throws {
        
        let origin = try Swizzle.Item(aClass: aClass, selector: selector)
        let new = try Swizzle.Item(aClass: newClass ?? aClass, selector: newSelector)
        origin.replace(with: new)
        
    }
    
    public static func unswizzle(selector: Selector,
                                 aClass: AnyClass) {
        guard let method = class_getInstanceMethod(aClass, selector) else {
            return
        }
        
        guard let swizzle = getSwizzle(with: method) else {
            return
        }
        
        swizzle.original.reset()
    }
}

//protocol Swizzler: NSObject {
//    associatedtype CFunction: NSObject
//    func originalSel() -> Selector
//    func newSel() -> Selector
//
//    func replace()
//    func reset()
//    func calloriginalFunc()
//}

//extension Swizzler {
//    func replace() {
//        let old = try! Swizzle.Item(aClass: self.classForCoder, selector: self.originalSel())
//        let new = try! Swizzle.Item(aClass: self.classForCoder, selector: self.newSel())
//        old.replace(with: new)
//    }
//    func reset() {
//        let old = try! Swizzle.Item(aClass: self.classForCoder, selector: self.originalSel())
//        old.reset()
//    }
//
//    func calloriginalFunc(parameter: Any) {
//        guard let method = class_getInstanceMethod(self.classForCoder, self.originalSel()),
//              let swizzler = Swizzle.getSwizzle(with: method) else {
//            return
//        }
//        let curriedImplementation = unsafeBitCast(swizzler.original.methodImp, to: CFunction.self)
////        curriedImplementation(ins, selector)
//        curriedImplementation(self, self.originalSel(), parameter)
//
//    }
//}
