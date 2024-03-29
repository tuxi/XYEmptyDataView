//
//  UIView+XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

private var emptyDataKey = "com.alpface.XYEmptyData.config"

extension UIView {
    
    public var emptyData: XYEmptyData? {
        get {
            return objc_getAssociatedObject(self, &emptyDataKey) as? XYEmptyData
        }
        set {
            objc_setAssociatedObject(self, &emptyDataKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue?.config.superview = self
            notifyEmptyDataDidChanged()
        }
    }
    
    @objc func notifyEmptyDataDidChanged() {
        setupEmptyDataView()
    }
    
    /// 初始化空数据视图
    func setupEmptyDataView() {
        guard let emptyData = self.emptyData else {
            return
        }
        emptyData.view.tapButonBlock = { [weak self] btn in
            guard let `self` = self,
                  let emptyData = self.emptyData,
                  let delegate = emptyData.delegate else {
                return
            }
            delegate.emptyData(emptyData, didTapButtonInState: emptyData.view.state!)
        }
        emptyData.view.tapContentViewBlock = { [weak self] contentView in
            guard let `self` = self,
                  let emptyData = self.emptyData,
                  let delegate = emptyData.delegate else {
                return
            }
            delegate.emptyData(emptyData, didTapContentViewInState: emptyData.view.state!)
        }
        emptyData.view.isHidden = true
    }
}

