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
            newValue?.bind.showView = self
            noticeEmptyDataDidChanged()
        }
    }
    
    @objc public func noticeEmptyDataDidChanged() {
        setupEmptyDataView()
    }
    
    @objc public func reloadEmptyDataView() {
        guard let emptyData = emptyData else {
            return
        }
        if let state = emptyData.state {
            emptyData.show(with: state)
        }
        else {
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
    }
}

