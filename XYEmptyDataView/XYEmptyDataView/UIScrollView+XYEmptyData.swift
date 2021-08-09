//
//  UIScrollView+XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

private var isRegisterEmptyDataViewKey = "com.alpface.XYEmptyData.registerEemptyDataView"

/// 为`UIScrollView.emptyData.delegate`扩展的关联状态的代理
/// 由于`UITableView`和`UICollectionView`的空数据显示与隐藏已关联其数据源，并自动管理，所以其显示的内容需要用户反馈一个state
public protocol XYEmptyDataStateDelegate: XYEmptyDataDelegate {
    
    /// 返回一个空数据的状态，比如在网络不好时返回无网络，或者某个特定的页面的状态
    func state(forEmptyData emptyData: XYEmptyData) -> XYEmptyDataState?
    
    /// 当前所在页面的数据源itemCount>0时，是否应该实现emptyDataView，default return `false`
    /// - Returns: 如果需要强制显示`emptyDataView`，return `true`即可
    func shouldForcedDisplay(forEmptyData emptyData: XYEmptyData) -> Bool
}

extension UIScrollView {
    
    /// 刷新空视图， 当执行`tableView`的`readData`、`endUpdates`或者`CollectionView`的`readData`时会调用此方法，外面无需主动调用
    public func reloadEmptyDataView() {
        if shouldDisplayEmptyDataView,
           let state = emptyDataState {
            self.emptyData?.show(with: state)
        } else {
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
        
        emptyData?.config.sizeObserver = SizeObserver(target: self, eventHandler: { [weak self] size in
            self?.reloadEmptyDataView()
        })
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
    
    /// 是否应该强制显示，即使有数据时，默认不需要的
    private var shouldForcedDisplayEmptyDataView: Bool {
        guard let emptyData = self.emptyData,
              let del = self.emptyData?.delegate as? XYEmptyDataStateDelegate else {
            return false
        }
        return del.shouldForcedDisplay(forEmptyData: emptyData)
    }
    
    private var emptyDataState: XYEmptyDataState? {
        guard let emptyData = self.emptyData else {
            return nil
        }
        if let stateDelegate = (emptyData.delegate as? XYEmptyDataStateDelegate) {
            return stateDelegate.state(forEmptyData: emptyData)
        }
        return emptyData.config.state
    }
    
    private var itemCount: Int {
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

public extension XYEmptyDataStateDelegate {
    func shouldForcedDisplay(forEmptyData emptyData: XYEmptyData) -> Bool {
        return false
    }
}

extension XYEmptyData {
    enum DefaultState: XYEmptyDataState {
        case empty
    }
}
