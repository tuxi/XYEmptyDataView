//
//  XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2018/1/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

public protocol XYEmptyDataState {
    var title: ((UILabel) -> Void)? { get }
    var button: ((UIButton) -> Void)? { get }
    var detail: ((UILabel) -> Void)? { get }
    var image: ((UIImageView) -> Void)? { get }
    var customView: UIView? { get }
}
public protocol XYEmptyDataDelegate: AnyObject {
    
    /// 点击空视图的`button`按钮的回调
    func emptyData(_ emptyData: XYEmptyData, didTapButton button: UIButton)
    
    /// 点击空视图的`contentView`回调
    func emptyData(_ emptyData: XYEmptyData, didTapContentView view: UIControl)
    
    /// 返回空数据显示的位置
    func position(forState state: XYEmptyDataState, inEmptyData emptyData: XYEmptyData) -> XYEmptyData.Position
}

public protocol XYEmptyDataAppearable: XYEmptyDataDelegate {
    /// 当空数据视图在显示或消失时回调
    func emptyData(_ emptyData: XYEmptyData, didChangedAppearStatus status: XYEmptyData.AppearStatus)
}

public struct XYEmptyData {
    public typealias Delegate = XYEmptyDataDelegate
    
    public var format = Format()
    public weak var delegate: Delegate?
    
    internal let config = ViewConfig()
    internal var view = XYEmptyDataView()
    
    public init() { }
    
    func updateView(for state: XYEmptyDataState) {
        let emptyData = self
        self.view.update(withEmptyData: emptyData, for: state)
    }
}

/// 扩展显示空数据的回调
internal extension XYEmptyData {
    /// 即将显示空数据时调用
    func viewWillAppear() {
        (self.delegate as? XYEmptyDataAppearable)?.emptyData(self, didChangedAppearStatus: .willAppear)
    }
    
    /// 已经显示空数据时调用
    func viewDidAppear() {
        (self.delegate as? XYEmptyDataAppearable)?.emptyData(self, didChangedAppearStatus: .didAppear)
    }
    
    /// 空数据即将消失时调用
    func viewWillDisappear() {
        (self.delegate as? XYEmptyDataAppearable)?.emptyData(self, didChangedAppearStatus: .willDisappear)
    }
    
    /// 空数据已经消失时调用
    func viewDidDisappear() {
        (self.delegate as? XYEmptyDataAppearable)?.emptyData(self, didChangedAppearStatus: .didDisappear)
    }
}

public extension XYEmptyData {
    /// 显示空视图
    func show(with state: XYEmptyDataState) {
        guard let showView = self.config.showView else {
            return
        }
        self.config.state = state
        viewWillAppear()
        self.view.show(on: showView, animated: true)
        self.updateView(for: state)
        viewDidAppear()
    }
    
    /// 隐藏空视图
    func hide() {
        viewWillDisappear()
        self.view.resetSubviews()
        self.view.contentView.alpha = 0
        viewDidDisappear()
        self.view.removeFromSuperview()
    }
}

internal extension XYEmptyData {
    var state: XYEmptyDataState? {
        set {
            config.state = newValue
        }
        get {
            return config.state
        }
    }
}

extension XYEmptyData {
    public enum Position {
        case center(offset: CGFloat = 0)
        case top(offset: CGFloat = 0)
        case bottom(offset: CGFloat = 0)
    }
    public enum AppearStatus {
        case willAppear
        case didAppear
        case willDisappear
        case didDisappear
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
        internal init() {}
        
        internal var destoryClosure: (() -> Void)?
        
        /// 由于`XYEmptyDataView`是在`scrollView.frame.size！= .zero`时才显示，
        /// 当scrollView的宽高发生改变时，导致空视图没机会显示
        /// `sizeObserver`就是解决这个问题
        internal var sizeObserver: SizeObserver?
        
        internal weak var showView: UIView?
        internal var state: XYEmptyDataState?
        
        deinit {
            destoryClosure?()
        }
    }
}

public extension XYEmptyDataAppearable {
    func emptyData(_ emptyData: XYEmptyData, didChangedAppearStatus status: XYEmptyData.AppearStatus) {}
}

public extension XYEmptyDataDelegate {
    
    func position(forState state: XYEmptyDataState, inEmptyData emptyData: XYEmptyData) -> XYEmptyData.Position {
        return .center(offset: 0)
    }
    
    func emptyData(_ emptyData: XYEmptyData, didTapButton button: UIButton) {
        
    }
    
    func state(forEmptyData emptyData: XYEmptyData) -> XYEmptyDataState {
        return XYEmptyData.DefaultState.empty
    }
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
