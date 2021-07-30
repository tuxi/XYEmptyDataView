//
//  XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2018/1/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

public protocol XYEmptyDataViewAppearable: XYEmptyDataDelegate {
    /// 当emptyDataView即将显示的回调
    func emptyDataView(willAppear scrollView: UIScrollView)
    
    /// 当emptyDataView完全显示的回调
    func emptyDataView(didAppear scrollView: UIScrollView)
    
    /// 当emptyDataView即将消失的回调
    func emptyDataView(willDisappear scrollView: UIScrollView)
    
    /// 当emptyDataView完全消失的回调
    func emptyDataView(didDisappear scrollView: UIScrollView)
}

@objc public protocol XYEmptyDataDelegate: NSObjectProtocol {
    
    /// 当前所在页面的数据源itemCount>0时，是否应该实现emptyDataView，default return NO
    /// - Returns: 如果需要强制显示emptyDataView，return YES即可
    @objc
    optional func emptyDataView(shouldForcedDisplay scrollView: UIScrollView) -> Bool
    
    /// 点击空视图的`button`回调
    @objc
    optional func emptyDataView(_ scrollView: UIScrollView, didTapButton button: UIButton)
    
}

/// 空数据模型
public struct XYEmptyData {
    public typealias Delegate = XYEmptyDataDelegate
    public enum Position {
        case center(offset: CGFloat = 0)
        case top(offset: CGFloat = 0)
        case bottom(offset: CGFloat = 0)
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
