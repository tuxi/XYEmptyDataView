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
    static var isRegisterEmptyDataView = "com.alpface.XYEmptyData.registerEemptyDataView"
    static var config = "com.alpface.XYEmptyData.config"
}

extension UIView {
    
    public var emptyData: XYEmptyData? {
        get {
            return objc_getAssociatedObject(self, &XYEmptyDataKeys.config) as? XYEmptyData
        }
        set {
            objc_setAssociatedObject(self, &XYEmptyDataKeys.config, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            isRegisterEmptyDataView = registerEmptyDataView()
        }
    }
    
    private var isRegisterEmptyDataView: Bool {
        set {
            objc_setAssociatedObject(self, &XYEmptyDataKeys.isRegisterEmptyDataView, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &XYEmptyDataKeys.isRegisterEmptyDataView) as? Bool ?? false
        }
    }
    
    @objc public func registerEmptyDataView() -> Bool {
        setupEmptyDataView()
        return isRegisterEmptyDataView
    }
    
    @objc public func reloadEmptyDataView() {
        guard let emptyData = emptyData else {
            return
        }
        switch emptyData.view.status {
        case .show:
            emptyData.show(on: self, animated: true)
        case .hide:
            emptyData.hide()
        }
    }
    
    /// 初始化空数据视图
    func setupEmptyDataView() {
        guard let emptyData = self.emptyData else {
            return
        }
        
        emptyData.view.tapButonBlock = { [weak self] btn in
            guard let `self` = self,
                  let del = self.emptyData?.delegate else {
                return
            }
            del.emptyData(self.emptyData!, didTapButton: btn)
        }
        emptyData.view.isHidden = true
        
        emptyData.bind.destoryClosure = { [weak self] in
            //                    guard let `self` = self else {
            //                        return
            //                    }
            //                    self?.unregisterEmptyDataView()
        }
        
        emptyData.bind.sizeObserver = SizeObserver(target: self, eventHandler: { [weak self] size in
            self?.reloadEmptyDataView()
        })
    }
    
    /// 点击空数据视图的 reload的回调
    private func xy_clickButton(btn: UIButton) {
        
    }
}


extension UIView: XYEmptyDataViewable {}
