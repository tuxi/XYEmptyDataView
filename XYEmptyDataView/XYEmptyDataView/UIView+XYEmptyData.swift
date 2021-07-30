//
//  UIView+XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

/// 用于关联对象的keys
private struct XYEmptyDataKeys {
    static var emptyDataView = "com.alpface.XYEmptyData.emptyDataView"
    static var registerEmptyDataView = "com.alpface.XYEmptyData.registerEemptyDataView"
    static var config = "com.alpface.XYEmptyData.config"
}

extension XYEmptyDataViewable where Self: UIScrollView {
    public var emptyData: XYEmptyData? {
        get {
            return objc_getAssociatedObject(self, &XYEmptyDataKeys.config) as? XYEmptyData
        }
        set {
            objc_setAssociatedObject(self, &XYEmptyDataKeys.config, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            registerEmptyDataView()
            registerEmptyDataView()
        }
    }
    
}

extension UIScrollView: XYEmptyDataViewable {}
