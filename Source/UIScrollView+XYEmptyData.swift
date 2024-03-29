//
//  UIScrollView+XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

private var isRegisterEmptyDataViewKey = "com.alpface.XYEmptyData.registerEemptyDataView"

/// 为 `UICollectionView` 和 `UITableView` 空数据扩展的delegate
public protocol XYEmptyDataDelegateAuto {
    /// 当不符合显示时，是否强制显示
    func shouldForceDisplay(forState state: XYEmptyDataState, inEmptyData emptyData: XYEmptyData) -> Bool
    /// 应该显示或隐藏，默认不需要实现，由dataSource 计算，适用于
    func shouldDisplay(forState state: XYEmptyDataState, inEmptyData emptyData: XYEmptyData) -> Bool
}

extension UIScrollView {
    
    /// 刷新空视图， 当执行`tableView`的`readData`、`endUpdates`或者`CollectionView`的`readData`时会调用此方法，外面无需主动调用
    fileprivate func reloadEmptyDataView() {
        guard let state = self.emptyData?.state else {
            self.emptyData?.hide()
            return
        }
        var shouldDisplay = shouldDisplayEmptyDataView
        if let delegate = self.emptyData?.delegate as? XYEmptyDataDelegateAuto {
            if !shouldDisplay {
                shouldDisplay = delegate.shouldForceDisplay(forState: state, inEmptyData: self.emptyData!)
            }
        }
        if shouldDisplay {
            self.emptyData?.show(with: state)
        }
        else {
            self.emptyData?.hide()
        }
    }
    
    fileprivate var isRegisterEmptyDataView: Bool {
        set {
            objc_setAssociatedObject(self, &isRegisterEmptyDataViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &isRegisterEmptyDataViewKey) as? Bool ?? false
        }
    }
    override func notifyEmptyDataDidChanged() {
        if let tableView = self as? UITableView {
            tableView.registerEmptyDataView()
        }
        if let collectionView = self as? UICollectionView {
            collectionView.registerEmptyDataView()
        }
        
        emptyData?.config.sizeObserver = SizeObserver(target: self, eventHandler: { [weak self] keyPath  in
            self?.reloadEmptyDataView()
        })
    }
}

/// 扩展显示空数据的条件
private extension UIScrollView {
    /// 是否应该显示
    var shouldDisplayEmptyDataView: Bool {
        var shouldDisplay = emptyData != nil && !frame.size.equalTo(.zero)
        if !shouldDisplay {
            return shouldDisplay
        }
        if let delegate = self.emptyData?.delegate as? XYEmptyDataDelegateAuto {
            shouldDisplay = delegate.shouldDisplay(forState: self.emptyData!.state!, inEmptyData: self.emptyData!)
        }
        if !shouldDisplay {
            return shouldDisplay
        }
        return itemCount <= 0
    }
    
    var itemCount: Int {
        var itemCount = 0
        
        let selectorName = "dataSource"
        
        if self.responds(to: NSSelectorFromString(selectorName)) == false {
            return itemCount
        }
        
        // UITableView
        if let tableView = self as? UITableView {
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
                if sections > 0 {
                    for section in 0...(sections - 1) {
                        itemCount += dataSource.tableView(tableView, numberOfRowsInSection: section)
                    }
                }
            }
        }
        
        // UICollectionView
        if let collectionView = self as? UICollectionView {
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

extension UITableView {
    
    fileprivate func registerEmptyDataView() {
        if self.isRegisterEmptyDataView {
            return
        }
        
        guard self.emptyData != nil else {
            return
        }
        isRegisterEmptyDataView = true
        self.setupEmptyDataView()
        
        // 对reloadData方法的实现进行处理, 为加载reloadData时注入额外的实现
        try! Swizzler.swizzle(selector: #selector(reloadData),
                              newSelector: #selector(swizzleReloadData),
                              aClass: UITableView.self)
        
        try! Swizzler.swizzle(selector: #selector(endUpdates),
                              newSelector: #selector(swizzleEndUpdates),
                              aClass: UITableView.self)
    }
    
    @objc private func swizzleReloadData() {
        //        swizzleReloadData()
        let origin = try! Swizzler.Func(aClass: UITableView.self,
                                        selector: #selector(reloadData))
        origin.callFunction(withInstance: self)
        reloadEmptyDataView()
    }
    
    @objc private func swizzleEndUpdates() {
        //        swizzleEndUpdates()
        try! Swizzler.Func(aClass: UITableView.self,
                           selector: #selector(endUpdates))
            .callFunction(withInstance: self)
        
        reloadEmptyDataView()
    }
}
extension UICollectionView {
    fileprivate func registerEmptyDataView() {
        if self.isRegisterEmptyDataView {
            return
        }
        
        guard self.emptyData != nil else {
            return
        }
        
        isRegisterEmptyDataView = true
        
        self.setupEmptyDataView()
        
        // 对reloadData方法的实现进行处理, 为加载reloadData时注入额外的实现
        try! Swizzler.swizzle(selector: #selector(reloadData),
                              newSelector: #selector(swizzleReloadData),
                              aClass: UICollectionView.self)
    }
    
    @objc private func swizzleReloadData() {
        //        swizzleReloadData()
        try! Swizzler.Func(aClass: UICollectionView.self,
                           selector: #selector(reloadData))
            .callFunction(withInstance: self)
        
        reloadEmptyDataView()
    }
}

extension XYEmptyDataDelegateAuto {
   public func shouldForceDisplay(forState state: XYEmptyDataState, inEmptyData emptyData: XYEmptyData) -> Bool {
        return false
    }
    
    public func shouldDisplay(forState state: XYEmptyDataState, inEmptyData emptyData: XYEmptyData) -> Bool {
        return true
    }
}
