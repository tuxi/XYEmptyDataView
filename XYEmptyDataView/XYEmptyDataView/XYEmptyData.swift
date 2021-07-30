//
//  XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2018/1/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

public enum XYEmptyDataAppearStatus {
    /// emptyDataView即将显示
    case willAppear
    /// emptyDataView完全显示
    case didAppear
    /// emptyDataView即将消失
    case willDisappear
    /// emptyDataView完全消失
    case didDisappear
}

public protocol XYEmptyDataViewAppearable: XYEmptyDataDelegate {
    /// 当emptyDataView即将显示的回调
    func emptyData(_ emptyData: XYEmptyData, onApperStatus status: XYEmptyDataAppearStatus)
}

public protocol XYEmptyDataDelegate: AnyObject {
    
    /// 当前所在页面的数据源itemCount>0时，是否应该实现emptyDataView，default return NO
    /// - Returns: 如果需要强制显示emptyDataView，return YES即可
    func shouldForcedDisplay(inEmptyData emptyData: XYEmptyData) -> Bool
    
    /// 点击空视图的`button`回调
    func emptyData(_ emptyData: XYEmptyData, didTapButton button: UIButton)
}

/// 空数据模型
public struct XYEmptyData {
    public typealias Delegate = XYEmptyDataDelegate
    public enum Position {
        case center(offset: CGFloat = 0)
        case top(offset: CGFloat = 0)
        case bottom(offset: CGFloat = 0)
    }
    /// 内部状态
    internal enum Status {
        case show, hide
    }
    /// `ViewBinder`分为两种视图：`default` 和 `custom`
    public class ViewBinder {
        internal var titleLabelClosure: ((UILabel) -> Void)?
        internal var detailLabelClosure: ((UILabel) -> Void)?
        internal var imageViewClosure: ((UIImageView) -> Void)?
        internal var buttonClosure: ((UIButton) -> Void)?
        
        internal var customView: (() -> UIView?)?
        internal var position: (() -> Position?)?
        internal init() {}
        
        internal var destoryClosure: (() -> Void)?
        
        /// 由于`XYEmptyDataView`是在`scrollView.frame.size！= .zero`时才显示，当scrollView的宽高发生改变时，导致空视图没机会显示
        /// `sizeObserver`就是解决这个问题
        internal var sizeObserver: SizeObserver?
        
        deinit {
            destoryClosure?()
        }
    }
    
    /// 对齐方法，分为：上、下、中间，修改的话需要调用`.bind.position`
    public let position: Position
    /// 内边距
    public var contentEdgeInsets: UIEdgeInsets = .zero
    /// view的背景颜色
    public var backgroundColor: UIColor?
    /// 空数据`contentView`的背景颜色
    public var contentBackgroundColor: UIColor?
    /// 各子控件之间垂直的间距，默认为11
    public var itemPadding: CGFloat = 11
    /// `imageView`的宽高，默认为`nil`，让其自适应
    public var imageSize: CGSize?
    public weak var delegate: Delegate?
    public let bind = ViewBinder()
    internal var view = XYEmptyDataView()
    public init(position: Position) {
        self.position = position
    }
    
    func updateView() {
        let emptyData = self
        self.view.update(withEmptyData: emptyData)
    }
}

public extension XYEmptyDataViewAppearable {
    func emptyDataView(willAppear scrollView: UIScrollView) {}
    func emptyDataView(didAppear scrollView: UIScrollView) {}
    func emptyDataView(willDisappear scrollView: UIScrollView) {}
    func emptyDataView(didDisappear scrollView: UIScrollView) {}
}



extension XYEmptyData.ViewBinder {
    @discardableResult
    public func title(_ closure: @escaping (UILabel) -> Void) -> Self {
        self.titleLabelClosure = closure
        return self
    }
    @discardableResult
    public func detail(_ closure: @escaping (UILabel) -> Void) -> Self {
        self.detailLabelClosure = closure
        return self
    }

    @discardableResult
    public func button(_ closure: @escaping (UIButton) -> Void) -> Self {
        self.buttonClosure = closure
        return self
    }
    @discardableResult
    public func image(_ closure: @escaping (UIImageView) -> Void) -> Self {
        self.imageViewClosure = closure
        return self
    }

    @discardableResult
    public func custom(_ closure: @escaping () -> UIView?) -> Self {
        self.customView = closure
        return self
    }
    @discardableResult
    public func position(_ closure: @escaping () -> XYEmptyData.Position?) -> Self {
        self.position = closure
        return self
    }
}

internal class SizeObserver: NSObject {
    private weak var target: UIView?
    private var eventHandler: (_ size: CGSize) -> Void
    private let keyPath = "bounds"
    init(target: UIView, eventHandler: @escaping (_ size: CGSize) -> Void) {
        self.eventHandler = eventHandler
        super.init()
        self.target = target
        target.addObserver(self, forKeyPath: keyPath, options: [.old, .new, .initial], context: nil)
    }
    
    deinit {
        target?.removeObserver(self, forKeyPath: keyPath)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let new = change?[.newKey] as? CGRect ?? .zero
        let old = change?[.oldKey] as? CGRect ?? .zero
        if keyPath == self.keyPath, !old.size.equalTo(new.size) {
            eventHandler(new.size)
        }
    }
}

extension XYEmptyDataDelegate {
    func shouldForcedDisplay(inEmptyData emptyData: XYEmptyData) -> Bool {
        return false
    }
}

/// 扩展显示空数据的回调
extension XYEmptyData {
    /// 即将显示空数据时调用
    func emptyDataViewWillAppear() {
        (self.delegate as? XYEmptyDataViewAppearable)?.emptyData(self, onApperStatus: .willAppear)
    }
    
    /// 已经显示空数据时调用
    func emptyDataViewDidAppear() {
        (self.delegate as? XYEmptyDataViewAppearable)?.emptyData(self, onApperStatus: .didAppear)
    }
    
    /// 空数据即将消失时调用
    func emptyDataViewWillDisappear() {
        (self.delegate as? XYEmptyDataViewAppearable)?.emptyData(self, onApperStatus: .willDisappear)
    }
    
    /// 空数据已经消失时调用
    func emptyDataViewDidDisappear() {
        (self.delegate as? XYEmptyDataViewAppearable)?.emptyData(self, onApperStatus: .didDisappear)
    }
}


extension XYEmptyData {
    /// 显示空视图
    func show(on view: UIView, animated: Bool) {
        emptyDataViewWillAppear()
        self.view.show(withView: view, animated: animated)
        self.updateView()
        emptyDataViewDidAppear()
        self.view.status = .show
    }
    
    /// 隐藏空视图
    func hide() {
        emptyDataViewWillDisappear()
        self.view.resetSubviews()
        self.view.removeFromSuperview()
        self.view.contentView.alpha = 0
        emptyDataViewDidDisappear()
        self.view.status = .hide
    }
}
