//
//  Swizzler.swift
//  Swizzler
//
//  Created by xiaoyuan on 2021/7/29.
//

import Foundation

public struct Swizzler {
    public let original: Func
    public var new: Func
    
    init(original: Func,
         new: Func) {
        self.new = new
        self.original = original
    }
    
    public var description: String {
        var retValue = "Swizzle on \(String(describing: self.original.aClass))::\(NSStringFromSelector(original.selector)) ["
        retValue += "\t\(String(describing: new.aClass)) : \(String(describing: new.selector))\n"
        return retValue + "]"
    }
    
    public struct Func {
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
            
            guard let swizzle = Swizzler.getSwizzle(with: method) else {
                return
            }
            /// 恢复原方法的调用，必须用`swizzle.original`去还原
            method_setImplementation(swizzle.original.method, swizzle.original.methodImp)
            Swizzler.removeSwizzle(for: method)
        }
        
        /// 替换方法实现
        public func replace(with new: Swizzler.Func) {
            
            let method = self.method
            
            if Swizzler.getSwizzle(with: method) != nil {
                // 已经交换过，防止被重复交换
                return
            }
            let swizzle = Swizzler(original: self, new: new)
            
            let isAddSuccess = class_addMethod(new.aClass,
                                               self.selector,
                                               new.methodImp,
                                               method_getTypeEncoding(new.method))
            if isAddSuccess {
                // 方法添加成功，意味着当前类在添加之前并没有origin的方法
                // 添加成功后，就可以进行方法替换了，将原方法替换为新的方法实现即可
                class_replaceMethod(self.aClass, self.selector, new.methodImp, method_getTypeEncoding(new.method))
                   
            }
            else {
                // 方法添加失败，说明当前类已经存在该方法，直接替换实现
                method_setImplementation(method, new.methodImp)
                method_setImplementation(new.method, methodImp)
            }
            Swizzler.setSwizzle(swizzle, for: method)
        }
        
        /// 调用原方法实现，只能响应没有参数的方法，有参数的由于类型不确定，在调用时传递的都是空，所以需要自己重写
        func callFunction(withInsatnce ins: NSObject) {
            guard let method = class_getInstanceMethod(aClass, selector),
                  let swizzler = Swizzler.getSwizzle(with: method) else {
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

extension Swizzler.Func: Equatable {
    public static func == (lhs: Swizzler.Func, rhs: Swizzler.Func) -> Bool {
        lhs.aClass == rhs.aClass && lhs.selector == rhs.selector
    }
}

extension Swizzler.Func: CustomStringConvertible {
    public var description: String {
        return "Func [\(String(describing: self.aClass))::\(NSStringFromSelector(self.selector))]"
        
    }
}

/// 扩展缓存，避免重复
extension Swizzler {
    public static var swizzles = [Method: Swizzler]()
    
    public static func getSwizzle(with method: Method) -> Swizzler? {
        return swizzles[method]
    }
    
    fileprivate static func removeSwizzle(for method: Method) {
        swizzles.removeValue(forKey: method)
    }
    
    fileprivate static func setSwizzle(_ swizzle: Swizzler, for method: Method) {
        swizzles[method] = swizzle
    }
    
    public static func swizzle(selector: Selector,
                               newSelector: Selector,
                               aClass: AnyClass,
                               newClass: AnyClass? = nil) throws {
        
        let origin = try Swizzler.Func(aClass: aClass, selector: selector)
        let new = try Swizzler.Func(aClass: newClass ?? aClass,
                                    selector: newSelector)
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
