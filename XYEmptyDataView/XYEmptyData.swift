//
//  XYEmptyData.swift
//  XYEmptyDataView
//
//  Created by swae on 2018/1/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc public protocol NoDataPlaceholderDelegate: NSObjectProtocol {
    
    
    /// 是否应该淡入淡出，default is YES
    @objc @available(iOS 2.0, *)
    optional func noDataPlaceholderShouldFadeIn(onDisplay scrollView: UIScrollView) -> Bool
    
    
    /// 是否应显示NoDataPlaceholderView, 默认YES
    /// @return 如果当前无数据则应显示NoDataPlaceholderView
    @objc @available(iOS 2.0, *)
    optional func noDataPlaceholderShouldDisplay(_ scrollView: UIScrollView) -> Bool
    
    
    /// 当前所在页面的数据源itemCount>0时，是否应该实现NoDataPlaceholder，default return NO
    /// @return 如果需要强制显示NoDataPlaceholder，return YES即可
    @objc @available(iOS 2.0, *)
    optional func noDataPlaceholderShouldBeForced(toDisplay scrollView: UIScrollView) -> Bool
    
    
    /// 当noDataPlaceholder即将显示的回调
    @objc @available(iOS 2.0, *)
    optional func noDataPlaceholderWillAppear(_ scrollView: UIScrollView)
    
    
    /// 当noDataPlaceholder完全显示的回调
    @objc @available(iOS 2.0, *)
    optional func noDataPlaceholderDidAppear(_ scrollView: UIScrollView)
    
    
    /// 当noDataPlaceholder即将消失的回调
    @objc @available(iOS 2.0, *)
    optional  func noDataPlaceholderWillDisappear(_ scrollView: UIScrollView)
    
    
    /// 当noDataPlaceholder完全消失的回调
    @objc @available(iOS 2.0, *)
    optional func noDataPlaceholderDidDisappear(_ scrollView: UIScrollView)
    
    
    /// noDataPlaceholder是否可以响应事件，默认YES
    @objc @available(iOS 2.0, *)
    optional func noDataPlaceholderShouldAllowResponseEvent(_ scrollView: UIScrollView) -> Bool
    
    
    /// noDataPlaceholder是否可以滚动，默认YES
    @objc @available(iOS 2.0, *)
    optional func noDataPlaceholderShouldAllowScroll(_ scrollView: UIScrollView) -> Bool
    
    
    @objc @available(iOS 3.2, *)
    optional func noDataPlaceholder(_ scrollView: UIScrollView, didTapOnContentView tap: UITapGestureRecognizer)
    
    
    @objc @available(iOS 2.0, *)
    optional func noDataPlaceholder(_ scrollView: UIScrollView, didClickReload button: UIButton)
    
    
    /// NoDataPlaceholderView各子控件之间垂直的间距，默认为11
    @objc @available(iOS 2.0, *)
    optional func contentSubviewsGlobalVerticalSpaceFoNoDataPlaceholder(_ scrollView: UIScrollView) -> CGFloat
    
    
    /// NoDataPlaceholderView 的 contentView左右距离父控件的间距值
    @objc @available(iOS 2.0, *)
    optional func contentViewHorizontalSpaceFoNoDataPlaceholder(_ scrollView: UIScrollView) -> CGFloat
    
    
    /// NoDataPlaceholderView 顶部 和 左侧 相对 父控件scrollView 顶部 的偏移量, default is 0,0
    @objc @available(iOS 2.0, *)
    optional func contentOffset(forNoDataPlaceholder scrollView: UIScrollView) -> CGPoint
    
    
    /// imageView的size, 有的时候图片本身太大，导致imageView的尺寸并不是我们想要的，可以通过此方法设置, 当为CGSizeZero时不设置,默认为CGSizeZero
    @objc @available(iOS 2.0, *)
    optional func imageViewSize(forNoDataPlaceholder scrollView: UIScrollView) -> CGSize
}


extension UIScrollView {
    
    /// 用于关联对象的keys
    private struct EmptyDataKeys {
        static var delegate = "com.alpface.XYEmptyData.delete"
        static var customNoDataView = "com.alpface.XYEmptyData.customNoDataView"
        static var noDataTextLabelBlock = "com.alpface.XYEmptyData.noDataTextLabelBlock"
        static var noDataDetailTextLabelBlock = "com.alpface.XYEmptyData.noDataDetailTextLabelBlock"
        static var noDataImageViewBlock = "com.alpface.XYEmptyData.noDataImageViewBlock"
        static var noDataReloadButtonBlock = "com.alpface.XYEmptyData.noDataReloadButtonBlock"
        
        static var noDataTextEdgeInsets = "com.alpface.XYEmptyData.noDataTextEdgeInsets"
        static var noDataImageEdgeInsets = "com.alpface.XYEmptyData.noDataImageEdgeInsets"
        static var noDataDetailEdgeInsets = "com.alpface.XYEmptyData.noDataDetailEdgeInsets"
        static var noDataButtonEdgeInsets = "com.alpface.XYEmptyData.noDataButtonEdgeInsets"
        
        static var noDataViewBackgroundColor = "com.alpface.XYEmptyData.noDataViewBackgroundColor"
        static var noDataViewContentBackgroundColor = "com.alpface.XYEmptyData.noDataViewContentBackgroundColor"
        static var xy_loading = "com.alpface.XYEmptyData.xy_loading"
        
        static var noDataPlaceholderView = "com.alpface.XYEmptyData.noDataPlaceholderView"
        static var registerNoDataPlaceholder = "com.alpface.XYEmptyData.registerNoDataPlaceholder"
        static var delegateFlags = "com.alpface.XYEmptyData.delegateFlags"
        
        static var noDataTextLabel = "com.alpface.XYEmptyData.noDataTextLabel"
        static var noDataDetailTextLabel = "com.alpface.XYEmptyData.noDataTextLabel.noDataDetailTextLabel"
        static var noDataImageView = "com.alpface.XYEmptyData.noDataTextLabel.noDataImageView"
        static var noDataReloadButton = "com.alpface.XYEmptyData.noDataTextLabel.noDataReloadButton"
    }
    
    weak open var noDataPlaceholderDelegate: NoDataPlaceholderDelegate? {
        get {
            let delegateCon = objc_getAssociatedObject(self, &EmptyDataKeys.delegate) as? _WeakObjectContainer
            if let delegate = delegateCon?.weakObject as? NoDataPlaceholderDelegate {
                return delegate
            }
            return nil
        }
        set {
            if (noDataPlaceholderDelegate?.isEqual(newValue))! {
                return
            }
            
            objc_setAssociatedObject(self, &EmptyDataKeys.delegate, _WeakObjectContainer(weakObject: newValue as AnyObject), .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    
    /// use custom view
    open var customNoDataView: (() -> UIView)? {
        get {
            if let callBack = objc_getAssociatedObject(self, EmptyDataKeys.customNoDataView) as? () -> UIView {
                return callBack
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.customNoDataView, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    
    // setup subviews
    open var noDataTextLabelBlock: ((UILabel) -> Swift.Void)? {
        get {
            if let callBack = objc_getAssociatedObject(self, EmptyDataKeys.noDataTextLabelBlock) as? (UILabel) -> Swift.Void {
                return callBack
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataTextLabelBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    open var noDataDetailTextLabelBlock: ((UILabel) -> Swift.Void)? {
        get {
            if let callBack = objc_getAssociatedObject(self, EmptyDataKeys.noDataDetailTextLabelBlock) as? (UILabel) -> Swift.Void {
                return callBack
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataDetailTextLabelBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    open var noDataImageViewBlock: ((UIImageView) -> Swift.Void)? {
        get {
            if let callBack = objc_getAssociatedObject(self, EmptyDataKeys.noDataImageViewBlock) as? (UIImageView) -> Swift.Void {
                return callBack
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataImageViewBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    open var noDataReloadButtonBlock: ((UIButton) -> Swift.Void)? {
        get {
            if let callBack = objc_getAssociatedObject(self, EmptyDataKeys.noDataReloadButtonBlock) as? (UIButton) -> Swift.Void {
                return callBack
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataReloadButtonBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    
    /// titleLabel 的间距
    open var noDataTextEdgeInsets: UIEdgeInsets {
        get {
            if let obj = objc_getAssociatedObject(self, EmptyDataKeys.noDataTextEdgeInsets) as? NSValue {
                return obj.uiEdgeInsetsValue
            }
            return UIEdgeInsets.zero
        }
        set {
            let value : NSValue = NSValue.init(uiEdgeInsets: newValue)
            
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataTextEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// imageView 的间距
    open var noDataImageEdgeInsets: UIEdgeInsets {
        get {
            if let obj = objc_getAssociatedObject(self, EmptyDataKeys.noDataImageEdgeInsets) as? NSValue {
                return obj.uiEdgeInsetsValue
            }
            return UIEdgeInsets.zero
        }
        set {
            let value : NSValue = NSValue.init(uiEdgeInsets: newValue)
            
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataImageEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// detaileLable 的间距
    open var noDataDetailEdgeInsets: UIEdgeInsets {
        get {
            if let obj = objc_getAssociatedObject(self, EmptyDataKeys.noDataDetailEdgeInsets) as? NSValue {
                return obj.uiEdgeInsetsValue
            }
            return UIEdgeInsets.zero
        }
        set {
            let value : NSValue = NSValue.init(uiEdgeInsets: newValue)
            
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataDetailEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// reloadButton 的间距
    open var noDataButtonEdgeInsets: UIEdgeInsets {
        get {
            if let obj = objc_getAssociatedObject(self, EmptyDataKeys.noDataButtonEdgeInsets) as? NSValue {
                return obj.uiEdgeInsetsValue
            }
            return UIEdgeInsets.zero
        }
        set {
            let value : NSValue = NSValue.init(uiEdgeInsets: newValue)
            
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataButtonEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    /// noDataPlaceholderView 的背景颜色
    open var noDataViewBackgroundColor: UIColor? {
        get {
            if let obj = objc_getAssociatedObject(self, EmptyDataKeys.noDataViewBackgroundColor) as? UIColor {
                return obj
            }
            return nil
        }
        set {
  
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataViewBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// noDataPlaceholderView中contentView的背景颜色
    open var noDataViewContentBackgroundColor: UIColor? {
        get {
            if let obj = objc_getAssociatedObject(self, EmptyDataKeys.noDataViewContentBackgroundColor) as? UIColor {
                return obj
            }
            return nil
        }
        set {
            
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataViewContentBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open var xy_loading: Bool {
        get {
            if let obj = objc_getAssociatedObject(self, EmptyDataKeys.xy_loading) as? NSNumber {
                return obj.boolValue
            }
            return false
        }
        set {
            
            objc_setAssociatedObject(self, &EmptyDataKeys.xy_loading, NSNumber.init(value: xy_loading), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var noDataPlaceholderView: NoDataPlaceholderView? {
        get {
            if let view = objc_getAssociatedObject(self, &EmptyDataKeys.noDataPlaceholderView) as? NoDataPlaceholderView {
                return view
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataPlaceholderView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var registerNoDataPlaceholder: Bool {
        get {
            if let num = objc_getAssociatedObject(self, &EmptyDataKeys.registerNoDataPlaceholder) as? NSNumber {
                return num.boolValue
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.registerNoDataPlaceholder, NSNumber.init(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var delegateFlags: NoDataPlaceholderDelegateFlags? {
        get {
            if let flags = objc_getAssociatedObject(self, &EmptyDataKeys.delegateFlags) as? NoDataPlaceholderDelegateFlags {
                return flags
            }
            return nil
        }
        set {
           objc_setAssociatedObject(self, &EmptyDataKeys.delegateFlags, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    fileprivate var noDataTextLabel: (() -> UILabel)? {
        get {
            if let callBack = objc_getAssociatedObject(self, EmptyDataKeys.noDataTextLabel) as? () -> UILabel {
                return callBack
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataTextLabel, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    fileprivate var noDataDetailTextLabel: (() -> UILabel)? {
        get {
            if let callBack = objc_getAssociatedObject(self, EmptyDataKeys.noDataDetailTextLabel) as? () -> UILabel {
                return callBack
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataDetailTextLabel, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    fileprivate var noDataImageView: (() -> UIImageView)? {
        get {
            if let callBack = objc_getAssociatedObject(self, EmptyDataKeys.noDataImageView) as? () -> UIImageView {
                return callBack
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataImageView, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    fileprivate var noDataReloadButton: (() -> UIButton)? {
        get {
            if let callBack = objc_getAssociatedObject(self, EmptyDataKeys.noDataReloadButton) as? () -> UIButton {
                return callBack
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataReloadButton, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    
    /// 刷新NoDataView, 当执行tableView的readData、endUpdates或者CollectionView的readData时会调用此方法
    ////////////////////////////////////////////////////////////////////////
    open func xy_reloadNoData() {
        
    }
}

fileprivate struct _NoDataPlaceholderDelegateFlags {
    
    public var noDataPlacehodlerShouldDisplay: ObjCBool // 通过delegate方法决定是否应该显示noData
    
    public var noDataPlacehodlerShouldBeForcedToDisplay: ObjCBool // 当不可以显示noData时，是否强制显示
    
    public var noDataPlacehodlerCanDisplay: ObjCBool // 是否可以显示noData，根据当前noDataView所在的父控件确定
    
    public var itemCount: Int // 当前tableView或collectionView的总行数
    
    public var noDataPlacehodlerIsAllowedResponseEvent: ObjCBool // noDataView是否可以响应事件
    
    public var noDataPlacehodlerIsAllowedScroll: ObjCBool // 是否可以滚动
    
    public var noDataPlacehodlerGlobalVerticalSpace: CGFloat // noDataView 各子控件垂直之间的间距值，默认为10.0
    
    public var noDataPlacehodlerContentViewHorizontaSpace: CGFloat // contentView 左右距离父控件的间距值，默认为0
    
    public var noDataPlacehodlerContentOffset: CGPoint // NoDataPlaceholderView 顶部 和 左侧 相对 父控件scrollView 顶部 的偏移量, default is 0,0
    
    public init(noDataPlacehodlerShouldDisplay: ObjCBool, noDataPlacehodlerShouldBeForcedToDisplay: ObjCBool, noDataPlacehodlerCanDisplay: ObjCBool, itemCount: Int, noDataPlacehodlerIsAllowedResponseEvent: ObjCBool, noDataPlacehodlerIsAllowedScroll: ObjCBool, noDataPlacehodlerGlobalVerticalSpace: CGFloat, noDataPlacehodlerContentViewHorizontaSpace: CGFloat, noDataPlacehodlerContentOffset: CGPoint) {
        self.noDataPlacehodlerShouldDisplay = noDataPlacehodlerShouldDisplay
        self.noDataPlacehodlerCanDisplay = noDataPlacehodlerCanDisplay
        self.noDataPlacehodlerShouldBeForcedToDisplay = noDataPlacehodlerShouldBeForcedToDisplay
        self.itemCount = itemCount
        self.noDataPlacehodlerIsAllowedResponseEvent = noDataPlacehodlerIsAllowedResponseEvent
        self.noDataPlacehodlerIsAllowedScroll = noDataPlacehodlerIsAllowedScroll
        self.noDataPlacehodlerGlobalVerticalSpace = noDataPlacehodlerGlobalVerticalSpace
        self.noDataPlacehodlerContentViewHorizontaSpace = noDataPlacehodlerContentViewHorizontaSpace
        self.noDataPlacehodlerContentOffset = noDataPlacehodlerContentOffset
        
    }

}

fileprivate typealias NoDataPlaceholderDelegateFlags = _NoDataPlaceholderDelegateFlags


fileprivate let NoDataPlaceholderHorizontalSpaceRatioValue: CGFloat = 16.0

fileprivate class _WeakObjectContainer : NSObject {
    
    
    weak open var weakObject: AnyObject?
    
    
    public init(weakObject: AnyObject) {
        self.weakObject = weakObject
    }
}

fileprivate class _SwizzlingObject : NSObject {
    
    var swizzlingClass: Swift.AnyClass?
    
    var orginSelector: Selector?
    
    var swizzlingSelector: Selector?
    
    var swizzlingImplPointer: NSValue?
}

fileprivate extension NSObject {
    
    static let implementationDictionary = [String: _SwizzlingObject]()
    
    private func xy_baseClassToSwizzling() -> Swift.AnyClass {
        
    }
    
    ////////////////////////////////////////////////////////////////////////
    private func hockSelector(_ orginSelector: Selector, swizzlingSelector: Selector) {
        
    }
}

extension UIView {
    
    struct EmptyDataKeys {
        static var noDataPlaceholderViewContentEdgeInsets = "com.alpface.XYEmptyData.noDataPlaceholderViewContentEdgeInsets"
    }
    open var noDataPlaceholderViewContentEdgeInsets: UIEdgeInsets {
        get {
            if let obj = objc_getAssociatedObject(self, EmptyDataKeys.noDataPlaceholderViewContentEdgeInsets) as? NSValue {
                return obj.uiEdgeInsetsValue
            }
            return UIEdgeInsets.zero
        }
        set {
            let value : NSValue = NSValue.init(uiEdgeInsets: newValue)
            
            objc_setAssociatedObject(self, &EmptyDataKeys.noDataPlaceholderViewContentEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

fileprivate class NoDataPlaceholderView : UIView {
    
    
    /** 内容视图 */
    weak open var contentView: UIView?
    
    /** 标题label */
    weak open var titleLabel: UILabel?
    
    /** 详情label */
    weak open var detailLabel: UILabel?
    
    /** 图片视图 */
    weak open var imageView: UIImageView?
    
    /** 重新加载的button */
    weak open var reloadButton: UIButton?
    
    /** 自定义视图 */
    var customView: UIView?
    
    /** 点按手势 */
    var tapGesture: UITapGestureRecognizer
    
    /** self顶部距离父控件scrollView 顶部的偏移量 */
    var contentOffsetY: CGFloat
    
    /** self顶部距离父控件scrollView 左侧的偏移量 */
    var contentOffsetX: CGFloat
    
    /** contentView 左右距离父控件的间距 */
    var contentViewHorizontalSpace: CGFloat
    
    /** 所有子控件之间垂直间距 */
    var globalVerticalSpace: CGFloat
    
    /** 各子控件之间的边距，若设置此边距则 */
    var titleEdgeInsets: UIEdgeInsets
    
    var imageEdgeInsets: UIEdgeInsets
    
    var detailEdgeInsets: UIEdgeInsets
    
    var buttonEdgeInsets: UIEdgeInsets
    
    /** imageView的size, 有的时候图片本身太大，导致imageView的尺寸并不是我们想要的，可以通过此方法设置, 当为CGSizeZero时不设置,默认为CGSizeZero */
    var imageViewSize: CGSize
    
    /** tap手势回调block */
    var tapGestureRecognizerBlock: (UITapGestureRecognizer) -> Swift.Void
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 移除所有子控件及其约束
    func resetSubviews() {
        
    }
    
    /// 设置tap手势
    ////////////////////////////////////////////////////////////////////////
    func tapGestureRecognizer(_ tapBlock: @escaping (UITapGestureRecognizer) -> Swift.Void) {
        
    }
    

    ////////////////////////////////////////////////////////////////////////
    open class func show(to view: UIView, animated: Bool) -> Self {
        
    }
}

