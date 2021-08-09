//
//  XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2018/1/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

/// 展示空数据的状态， 根据此协议描述空数据的外观
public protocol XYEmptyDataState {
    var title: ((UILabel) -> Void)? { get }
    var button: ((UIButton) -> Void)? { get }
    var detail: ((UILabel) -> Void)? { get }
    var image: ((UIImageView) -> Void)? { get }
    var customView: UIView? { get }
}

/// 空数据的代理
public protocol XYEmptyDataDelegate: AnyObject {
    /// 点击空视图的`button`按钮的回调
    func emptyData(_ emptyData: XYEmptyData, didTapButton button: UIButton)
    /// 点击空视图的`contentView`回调
    func emptyData(_ emptyData: XYEmptyData, didTapContentView view: UIControl)
    /// 返回空数据显示的位置
    func position(forState state: XYEmptyDataState, inEmptyData emptyData: XYEmptyData) -> XYEmptyData.Position
    /// 空数据即将显示
    func willAppear(forEmptyData emptyData: XYEmptyData)
    /// 空数据已经显示
    func didAppear(forEmptyData emptyData: XYEmptyData)
    /// 空数据即将消失
    func willDisappear(forEmptyData emptyData: XYEmptyData)
    /// 空数据已经消失
    func didDisappear(forEmptyData emptyData: XYEmptyData)
}

/// 扩展的关联状态的代理
public protocol XYEmptyDataDelegateState: XYEmptyDataDelegate {
    
    /// 返回一个空数据的状态，比如在网络不好时返回无网络，或者某个特定的页面的状态
    func state(forEmptyData emptyData: XYEmptyData) -> XYEmptyDataState?
}

/// 空数据
public struct XYEmptyData {
    /// 空数据的格式化属性
    public var format = Format()
    /// 空数据代理
    public weak var delegate: XYEmptyDataDelegate?
    /// 内部属性，用于配制一些view的可变属性
    internal let config: ViewConfig
    /// 空数据的view
    internal let view = XYEmptyDataView()
    
    /// 初始化空数据
    ///
    /// - Parameters:
    ///   - state: 初始状态，如果实现`XYEmptyDataDelegateState`的状态绑定后， 此属性无效
    public static func with(state: XYEmptyDataState) -> XYEmptyData {
        return XYEmptyData(config: ViewConfig(state: state))
    }
}

/// 扩展显示空数据的回调
internal extension XYEmptyData {
    /// 即将显示空数据时调用
    func viewWillAppear() {
        self.delegate?.willAppear(forEmptyData: self)
    }
    /// 已经显示空数据时调用
    func viewDidAppear() {
        self.delegate?.didAppear(forEmptyData: self)
    }
    /// 空数据即将消失时调用
    func viewWillDisappear() {
        self.delegate?.willDisappear(forEmptyData: self)
    }
    /// 空数据已经消失时调用
    func viewDidDisappear() {
        self.delegate?.didDisappear(forEmptyData: self)
    }
}

public extension XYEmptyData {
    /// 根据一个状态显示空视图
    ///
    /// - Parameters:
    ///   - state: 临时状态，该状态不会被保存
    func show(with state: XYEmptyDataState) {
        guard let showView = self.config.superview else {
            return
        }
        viewWillAppear()
        self.view.show(on: showView, animated: true)
        let emptyData = self
        self.view.update(emptyData, for: state)
        viewDidAppear()
    }
    
    /// 根据初始状态显示空数据视图
    /// 如果实现`XYEmptyDataDelegateState`的状态绑定后，初始化状态无效
    func show() {
        if let state = state {
            show(with: state)
        } else {
            hide()
        }
    }
    
    /// 隐藏空视图
    func hide() {
        viewWillDisappear()
        self.view.resetSubviews()
        self.view.contentView.alpha = 0
        viewDidDisappear()
        self.view.removeFromSuperview()
    }
    
    /// 获取空数据的状态，如果实现了`XYEmptyDataDelegateState`，初始状态无效
    var state: XYEmptyDataState? {
        if let stateDelegate = (delegate as? XYEmptyDataDelegateState) {
            return stateDelegate.state(forEmptyData: self)
        }
        return config.state
    }
}

extension XYEmptyData {
    public enum Position {
        case center(offset: CGFloat = 0)
        case top(offset: CGFloat = 0)
        case bottom(offset: CGFloat = 0)
    }
    public struct Format {
        /// 内边距
        public var contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        /// view的背景颜色
        public var backgroundColor: UIColor?
        /// 空数据`contentView`的背景颜色
        public var contentBackgroundColor: UIColor?
        /// 各子控件之间垂直的间距，默认为11
        public var itemPadding: CGFloat = 11
        /// `imageView`的宽高，默认为`nil`，让其自适应
        public var imageSize: CGSize?
        
        public init() {}
    }

    internal class ViewConfig {
        internal init(state: XYEmptyDataState) {
            self.state = state
        }
        
        /// 释放（deinit）时执行的闭包
        internal var destoryClosure: (() -> Void)?
        
        /// 由于`XYEmptyDataView`是在`scrollView.frame.size！= .zero`时才显示，
        /// 当scrollView的宽高发生改变时，导致空视图没机会显示
        /// `sizeObserver`就是解决这个问题
        internal var sizeObserver: SizeObserver?
        /// 空数据view的父视图
        internal weak var superview: UIView?
        /// 展示空数据的状态
        internal let state: XYEmptyDataState
        
        deinit {
            destoryClosure?()
        }
    }
}

public extension XYEmptyDataDelegate {
    
    func position(forState state: XYEmptyDataState, inEmptyData emptyData: XYEmptyData) -> XYEmptyData.Position {
        return .center(offset: 0)
    }
    func emptyData(_ emptyData: XYEmptyData, didTapButton button: UIButton) {}
    func willAppear(forEmptyData emptyData: XYEmptyData) {}
    func didAppear(forEmptyData emptyData: XYEmptyData) {}
    func willDisappear(forEmptyData emptyData: XYEmptyData) {}
    func didDisappear(forEmptyData emptyData: XYEmptyData) {}
}

public extension XYEmptyDataState {
    var customView: UIView? {
        return nil
    }
    var image: ((UIImageView) -> Void)? {
        return nil
    }
    var detail: ((UILabel) -> Void)? {
        return nil
    }
    
    var title: ((UILabel) -> Void)? {
        return nil
    }
    var button: ((UIButton) -> Void)? {
        return nil
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
