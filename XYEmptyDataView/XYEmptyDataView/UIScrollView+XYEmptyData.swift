//
//  UIScrollView+XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

private var isRegisterEmptyDataViewKey = "com.alpface.XYEmptyData.registerEemptyDataView"

extension UIScrollView {
    
    /// 刷新空视图， 当执行`tableView`的`readData`、`endUpdates`或者`CollectionView`的`readData`时会调用此方法，外面无需主动调用
    public override func reloadEmptyDataView() {
        if let state = emptyData?.state, shouldDisplayEmptyDataView {
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
    override public func noticeEmptyDataDidChanged() {
        if let tableView = self as? UITableView {
            tableView.registerEmptyDataView()
        }
        if let collectionView = self as? UICollectionView {
            collectionView.registerEmptyDataView()
        }
        
        emptyData?.bind.sizeObserver = SizeObserver(target: self, eventHandler: { [weak self] size in
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
        guard let del = self.emptyData?.delegate else {
            return false
        }
        return del.shouldForcedDisplay(forEmptyData: self.emptyData!)
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
                              aClass: self.classForCoder)
        
        try! Swizzler.swizzle(selector: #selector(endUpdates),
                              newSelector: #selector(swizzleEndUpdates),
                              aClass: self.classForCoder)
    }
    
    @objc private func swizzleReloadData() {
        //        swizzleReloadData()
        let origin = try! Swizzler.Func(aClass: self.classForCoder,
                                        selector: #selector(reloadData))
        origin.callFunction(withInsatnce: self)
        reloadEmptyDataView()
    }
    
    @objc private func swizzleEndUpdates() {
        //        swizzleEndUpdates()
        try! Swizzler.Func(aClass: self.classForCoder,
                           selector: #selector(endUpdates))
            .callFunction(withInsatnce: self)
        
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
                              aClass: self.classForCoder)
    }
    
    @objc private func swizzleReloadData() {
        //        swizzleReloadData()
        try! Swizzler.Func(aClass: self.classForCoder,
                           selector: #selector(reloadData))
            .callFunction(withInsatnce: self)
        
        reloadEmptyDataView()
    }
}
