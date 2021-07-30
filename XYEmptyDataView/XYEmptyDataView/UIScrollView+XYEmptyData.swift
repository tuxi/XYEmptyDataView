//
//  UIScrollView+XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

private var registerEmptyDataViewKey = "_registerEmptyDataViewKey"

extension UIScrollView {
    
    private var isRegisterEmptyDataView: Bool {
        set {
            objc_setAssociatedObject(self, &registerEmptyDataViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &registerEmptyDataViewKey) as? Bool ?? false
        }
    }
    
    
    /// 初始化空数据视图
    private func setupEmptyDataView() {
        guard let emptyData = self.emptyData else {
            return
        }
        emptyData.view.tapButonBlock = { [weak self] btn in
            self?.xy_clickButton(btn: btn)
        }
        emptyData.view.isHidden = true
        
        emptyData.bind.destoryClosure = { [weak self] in
//                    guard let `self` = self else {
//                        return
//                    }
//                    self?.unregisterEmptyDataView()
        }
        
        emptyData.bind.sizeObserver = SizeObserver(target: self, eventHandler: { [weak self] size in
            self?.xy_reloadEmptyDataView()
        })
    }
    
    func registerEmptyDataView() {
        
        if isRegisterEmptyDataView == true {
            return
        }
        
        isRegisterEmptyDataView = true
        
        if !canDisplayEmptyDataView {
            self.hideEmptyDataView()
            self.emptyData?.bind.sizeObserver = nil
        }
        else {
            setupEmptyDataView()
            
            // 对reloadData方法的实现进行处理, 为加载reloadData时注入额外的实现
            try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("reloadData"))
                .replace(with: #selector(xy_reloadEmptyDataView))
            
            if self is UITableView {
                
                try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("endUpdates"))
                    .replace(with: #selector(xy_reloadEmptyDataView))
            }
        }
    }
    
    /// 最好不要移除，交换方法是针对所有实例
    private func unregisterEmptyDataView() {
        if canDisplayEmptyDataView {
            try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("reloadData"))
                .reset()
            if self is UITableView {
                try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("endUpdates"))
                    .reset()
            }
        }
    }
    
    /// 刷新空视图， 当执行`tableView`的`readData`、`endUpdates`或者`CollectionView`的`readData`时会调用此方法，外面无需主动调用
    @objc fileprivate func xy_reloadEmptyDataView() {
        if !canDisplayEmptyDataView {
            return
        }
        
        if shouldDisplayEmptyDataView {
            
            showEmptyDataView()
            emptyDataViewWillAppear()
            
            emptyData?.updateView()
            
            emptyDataViewDidAppear()
        } else {
            hideEmptyDataView()
        }
        
        try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("reloadData"))
            .callFunction(withInsatnce: self)
        
    }
    
    private func showEmptyDataView() {
        self.emptyData?.view.show(withView: self, animated: true)
    }
    
    private func hideEmptyDataView() {
        emptyDataViewWillDisappear()
        if let emptyData = self.emptyData {
            emptyData.view.resetSubviews()
            emptyData.view.removeFromSuperview()
            emptyData.view.contentView.alpha = 0
        }
        emptyDataViewDidDisappear()
    }
    
    /// 点击空数据视图的 reload的回调
    private func xy_clickButton(btn: UIButton) {
        guard let del = self.emptyData?.delegate else {
            return
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(_:didTapButton:))) {
            del.emptyDataView!(self, didTapButton: btn)
        }
    }

}


/// 扩展显示空数据的回调
private extension UIScrollView {
    /// 即将显示空数据时调用
    func emptyDataViewWillAppear() {
        (emptyData?.delegate as? XYEmptyDataViewAppearable)?.emptyDataView(willAppear: self)
    }
   
    /// 已经显示空数据时调用
    func emptyDataViewDidAppear() {
        (emptyData?.delegate as? XYEmptyDataViewAppearable)?.emptyDataView(didAppear: self)
    }

    /// 空数据即将消失时调用
    func emptyDataViewWillDisappear() {
        (emptyData?.delegate as? XYEmptyDataViewAppearable)?.emptyDataView(willDisappear: self)
    }
   
    /// 空数据已经消失时调用
    func emptyDataViewDidDisappear() {
        (emptyData?.delegate as? XYEmptyDataViewAppearable)?.emptyDataView(didDisappear: self)
    }
}

/// 扩展显示空数据的条件
private extension UIScrollView {
    /// 是否应该显示
    private var shouldDisplayEmptyDataView: Bool {
        return emptyData != nil &&
            !frame.size.equalTo(.zero) &&
            (itemCount <= 0 || shouldForcedDisplayEmptyDataView)
    }
    
    /// 是否应该强制显示,默认不需要的
    private var shouldForcedDisplayEmptyDataView: Bool {
        guard let del = self.emptyData?.delegate else {
            return false
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(shouldForcedDisplay:))) {
            return del.emptyDataView!(shouldForcedDisplay: self)
        }
        return false
    }
    
    // 是否符合显示
    private var canDisplayEmptyDataView: Bool {
        if  self is UITableView || self is UICollectionView {
            return true
        }
        return false
    }
    
    private var itemCount: Int {
        var itemCount = 0
        
        let selectorName = "dataSource"
        
        if self.responds(to: NSSelectorFromString(selectorName)) == false {
            return itemCount
        }
        
        // UITableView
        if self is UITableView {
            let tableView = self as! UITableView
            guard let dataSource = tableView.dataSource else {
                return itemCount
            }
            var sections = 1
            let selName1 = "numberOfSectionsInTableView:"
            if dataSource.responds(to: NSSelectorFromString(selName1)) {
                sections = dataSource.numberOfSections!(in: tableView)
            }
            let selName2 = "tableView:numberOfRowsInSection:"
            if dataSource.responds(to: NSSelectorFromString(selName2)) {
                // 遍历所有组获取每组的行数，就相加得到所有item的数量
                if sections > 0 {
                    for section in 0...(sections - 1) {
                        itemCount += dataSource.tableView(tableView, numberOfRowsInSection: section)
                    }
                }
                
            }
        }
        
        // UICollectionView
        if self is UICollectionView {
            let collectionView = self as! UICollectionView
            guard let dataSource = collectionView.dataSource else {
                return itemCount
            }
            
            var sections = 1
            let selName1 = "numberOfSectionsInCollectionView:"
            if dataSource.responds(to: NSSelectorFromString(selName1)) {
                sections = dataSource.numberOfSections!(in: collectionView)
            }
            let selName2 = "collectionView:numberOfItemsInSection:"
            if dataSource.responds(to: NSSelectorFromString(selName2)) {
                // 遍历所有组获取每组的行数，就相加得到所有item的数量
                if sections > 0 {
                    for section in 0...(sections - 1) {
                        itemCount += dataSource.collectionView(collectionView, numberOfItemsInSection: section)
                    }
                }
                
            }
        }
        return itemCount
    }
}
