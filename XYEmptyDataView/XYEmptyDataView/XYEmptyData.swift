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

public protocol XYEmptyDataState {
    var image: UIImage? { get }
    var title: String? { get }
    var detail: String? { get }
    var titleButton: String? { get }
    var customView: UIView? { get }
    
    var position: XYEmptyData.Position { get }
}

public protocol XYEmptyDataViewAppearable: XYEmptyDataDelegate {
    /// 当emptyDataView即将显示的回调
    func emptyData(_ emptyData: XYEmptyData, didChangedApperStatus status: XYEmptyDataAppearStatus)
}

public protocol XYEmptyDataDelegate: AnyObject {
    
    /// 点击空视图的`button`回调
    func emptyData(_ emptyData: XYEmptyData, didTapButton button: UIButton)
    
    /// 当前所在页面的数据源itemCount>0时，是否应该实现emptyDataView，default return `false`
    /// - Returns: 如果需要强制显示`emptyDataView`，return `true`即可
    func shouldForcedDisplay(forEmptyData emptyData: XYEmptyData) -> Bool
}

public protocol XYEmptyDataDataSource: AnyObject {
    func image(forEmptyData emptyData: XYEmptyData, inState state: XYEmptyDataState) -> UIImage?
    func title(forEmptyData emptyData: XYEmptyData, inState state: XYEmptyDataState) -> String?
    func detail(forEmptyData emptyData: XYEmptyData, inState state: XYEmptyDataState) -> String?
    func button(forEmptyData emptyData: XYEmptyData, inState state: XYEmptyDataState) -> String?
    func customView(forEmptyData emptyData: XYEmptyData, inState state: XYEmptyDataState) -> UIView?
    func position(forEmptyData emptyData: XYEmptyData, inState state: XYEmptyDataState) -> XYEmptyData.Position
}

public struct XYEmptyData {
    public typealias Delegate = XYEmptyDataDelegate
    public typealias DataSource = XYEmptyDataDataSource
    public enum Position {
        case center(offset: CGFloat = 0)
        case top(offset: CGFloat = 0)
        case bottom(offset: CGFloat = 0)
    }
    struct ViewModel {
        var image: UIImage?
        var title: String?
        var detail: String?
        var titleButton: String?
        var customView: UIView?
    }

    public class ViewBinder {
        internal var titleLabelClosure: ((UILabel) -> Void)?
        internal var detailLabelClosure: ((UILabel) -> Void)?
        internal var imageViewClosure: ((UIImageView) -> Void)?
        internal var buttonClosure: ((UIButton) -> Void)?
        
        internal var stateClosure: (() -> XYEmptyDataState)?
        
        internal init() {}
        
        internal var destoryClosure: (() -> Void)?
        
        /// 由于`XYEmptyDataView`是在`scrollView.frame.size！= .zero`时才显示，当scrollView的宽高发生改变时，导致空视图没机会显示
        /// `sizeObserver`就是解决这个问题
        internal var sizeObserver: SizeObserver?
        
        internal weak var showView: UIView?
        internal var state: XYEmptyDataState?
        
        deinit {
            destoryClosure?()
        }
    }
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
    public weak var dataSource: DataSource?
    public let bind = ViewBinder()
    internal var view = XYEmptyDataView()
    
    internal var state: XYEmptyDataState? {
        set {
            bind.state = newValue
        }
        get {
            return bind.state
        }
    }
    
    func updateView(for state: XYEmptyDataState) {
        let emptyData = self
        self.view.update(withEmptyData: emptyData, for: state)
    }
}

public extension XYEmptyDataViewAppearable {
    func emptyData(_ emptyData: XYEmptyData, didChangedApperStatus status: XYEmptyDataAppearStatus) {}
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
    public func state(_ closure: @escaping () -> XYEmptyDataState) -> Self {
        self.stateClosure = closure
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
    func shouldForcedDisplay(forEmptyData emptyData: XYEmptyData) -> Bool {
        return false
    }
}

/// 扩展显示空数据的回调
internal extension XYEmptyData {
    /// 即将显示空数据时调用
    func emptyDataViewWillAppear() {
        (self.delegate as? XYEmptyDataViewAppearable)?.emptyData(self, didChangedApperStatus: .willAppear)
    }
    
    /// 已经显示空数据时调用
    func emptyDataViewDidAppear() {
        (self.delegate as? XYEmptyDataViewAppearable)?.emptyData(self, didChangedApperStatus: .didAppear)
    }
    
    /// 空数据即将消失时调用
    func emptyDataViewWillDisappear() {
        (self.delegate as? XYEmptyDataViewAppearable)?.emptyData(self, didChangedApperStatus: .willDisappear)
    }
    
    /// 空数据已经消失时调用
    func emptyDataViewDidDisappear() {
        (self.delegate as? XYEmptyDataViewAppearable)?.emptyData(self, didChangedApperStatus: .didDisappear)
    }
}


public extension XYEmptyData {
    /// 显示空视图
    func show(with state: XYEmptyDataState) {
        guard let showView = self.bind.showView else {
            return
        }
        self.bind.state = state
        emptyDataViewWillAppear()
        self.view.show(on: showView, animated: true)
        self.updateView(for: state)
        emptyDataViewDidAppear()
    }
    
    /// 隐藏空视图
    func hide() {
        emptyDataViewWillDisappear()
        self.view.resetSubviews()
        self.view.contentView.alpha = 0
        emptyDataViewDidDisappear()
        self.view.removeFromSuperview()
    }
}

public extension XYEmptyDataState {
    var image: UIImage? {
        return nil
    }
    var title: String? {
        return nil
    }
    var detail: String? {
        return nil
    }
    var titleButton: String? {
        return nil
    }
    var customView: UIView? {
        return nil
    }
    
    var position: XYEmptyData.Position {
        return .center(offset: 0)
    }
    
}

extension XYEmptyDataDataSource {
    func position(forEmptyData emptyData: XYEmptyData, inState state: XYEmptyDataState) -> XYEmptyData.Position {
        return .center(offset: 0)
    }
}
