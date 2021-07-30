//
//  UIScrollView+XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit



extension UIScrollView {
    
    /// 刷新空视图， 当执行`tableView`的`readData`、`endUpdates`或者`CollectionView`的`readData`时会调用此方法，外面无需主动调用
    @objc public override func reloadEmptyDataView() {
        if shouldDisplayEmptyDataView {
            self.emptyData?.show(on: self, animated: true)
        } else {
            self.emptyData?.hide()
        }
        
        try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("reloadData"))
            .callFunction(withInsatnce: self)
    }
}

/// 扩展显示空数据的条件
private extension UIScrollView {
    /// 是否应该显示
    private var shouldDisplayEmptyDataView: Bool {
        if !canDisplayEmptyDataView {
            return false
        }
        return emptyData != nil &&
            !frame.size.equalTo(.zero) &&
            (itemCount <= 0 || shouldForcedDisplayEmptyDataView)
    }
    
    /// 是否应该强制显示,默认不需要的
    private var shouldForcedDisplayEmptyDataView: Bool {
        guard let del = self.emptyData?.delegate else {
            return false
        }
        return del.shouldForcedDisplay(inEmptyData: self.emptyData!)
    }
    
    // 是否符合显示
    var canDisplayEmptyDataView: Bool {
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

extension UITableView {
    override public func registerEmptyDataView() -> Bool {
        if super.registerEmptyDataView() {
            return true
        }
        guard let emptyData = self.emptyData else {
            return false
        }
        if !self.canDisplayEmptyDataView {
            self.emptyData?.hide()
            emptyData.bind.sizeObserver = nil
        }
        else {
            self.setupEmptyDataView()
            
            // 对reloadData方法的实现进行处理, 为加载reloadData时注入额外的实现
            try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("reloadData"))
                .replace(with: #selector(reloadEmptyDataView))
            
            try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("endUpdates"))
                .replace(with: #selector(reloadEmptyDataView))
        }
        return true
    }
    
    /// 最好不要移除，交换方法是针对所有实例
    func unregisterEmptyDataView() {
        if self.canDisplayEmptyDataView {
            try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("reloadData"))
                .reset()
            try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("endUpdates"))
                .reset()
        }
    }
}
extension UICollectionView {
    public override func registerEmptyDataView() -> Bool {
        if super.registerEmptyDataView() {
            return true
        }
        guard let emptyData = self.emptyData else {
            return false
        }
        if !self.canDisplayEmptyDataView {
            self.emptyData?.hide()
            emptyData.bind.sizeObserver = nil
        }
        else {
            self.setupEmptyDataView()
            
            // 对reloadData方法的实现进行处理, 为加载reloadData时注入额外的实现
            try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("reloadData"))
                .replace(with: #selector(reloadEmptyDataView))
        }
        return true
    }
    
    /// 最好不要移除，交换方法是针对所有实例
    func unregisterEmptyDataView() {
        if self.canDisplayEmptyDataView {
            try! Swizzle.Item(aClass: self.classForCoder, selector: NSSelectorFromString("reloadData"))
                .reset()
        }
    }
}
