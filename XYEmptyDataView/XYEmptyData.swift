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
    
    
    // MARK: - Lazy
    /** 内容视图 */
    lazy var contentView: UIView = {
        let contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        contentView.alpha = 0.0
        return contentView
    }()
    
    /** 标题label */
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 27.0)
        label.textColor = UIColor.init(white: 0.6, alpha: 1.0)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    /** 详情label */
    lazy var detailLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.textColor = UIColor.init(white: 0.6, alpha: 1.0)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    /** 图片视图 */
    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    /** 刷新按钮 */
    lazy open var reloadButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(NoDataPlaceholderView.clickReloadBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    /** 自定义视图 */
    var customView: UIView? {
        didSet {
            
            if let customV = self.customView {
                if customV.isEqual(oldValue) {
                    if !(customV.superview != nil)  {
                        self.contentView.addSubview(customV)
                    }
                    return;
                }
            }
            
            if let oldCustomView = oldValue {
                oldCustomView.removeFromSuperview()
            }
            
            if let customV = self.customView {
                customV.removeConstraints(customV.constraints)
                customV.translatesAutoresizingMaskIntoConstraints = false
                self.contentView.addSubview(customV)
            }
            
        }
    }
    
    /** 点按手势 */
    var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(NoDataPlaceholderView.tapGestureOnSelf(_:)))
        return tap
    }()
    
    /** self顶部距离父控件scrollView 顶部的偏移量 */
    var contentOffsetY: CGFloat = 0.0
    
    /** self顶部距离父控件scrollView 左侧的偏移量 */
    var contentOffsetX: CGFloat = 0.0
    
    /** contentView 左右距离父控件的间距 */
    var contentViewHorizontalSpace: CGFloat = 0.0
    
    /** 所有子控件之间垂直间距 */
    var globalVerticalSpace: CGFloat = 10.0
    
    /** 各子控件之间的边距，若设置此边距则 */
    var titleEdgeInsets: UIEdgeInsets {
        get {
            return titleLabel.noDataPlaceholderViewContentEdgeInsets
        }
        set {
            self.titleLabel.noDataPlaceholderViewContentEdgeInsets = newValue
        }
    }
    
    var imageEdgeInsets: UIEdgeInsets {
        get {
            return imageView.noDataPlaceholderViewContentEdgeInsets
        }
        set {
            self.imageView.noDataPlaceholderViewContentEdgeInsets = newValue
        }
    }
    
    var detailEdgeInsets: UIEdgeInsets {
        get {
            return detailLabel.noDataPlaceholderViewContentEdgeInsets
        }
        set {
            self.detailLabel.noDataPlaceholderViewContentEdgeInsets = newValue
        }
    }
    
    var buttonEdgeInsets: UIEdgeInsets {
        get {
            return reloadButton.noDataPlaceholderViewContentEdgeInsets
        }
        set {
            self.reloadButton.noDataPlaceholderViewContentEdgeInsets = newValue
        }
    }
    
    /** imageView的size, 有的时候图片本身太大，导致imageView的尺寸并不是我们想要的，可以通过此方法设置, 当为CGSizeZero时不设置,默认为CGSizeZero */
    var imageViewSize: CGSize = .zero
    
    /** tap手势回调block */
    var tapGestureRecognizerBlock: ((UITapGestureRecognizer) -> Swift.Void)?
    
    convenience init(_ view: UIView) {
        self.init(frame: view.bounds)
        
        if (self.superview == nil) {
            if view is UITableView || view is UICollectionView {
                if view.subviews.count > 1 {
                    view.insertSubview(self, at: 0)
                }
                else {
                    view.addSubview(self)
                }
            }
        }
        var widthConstant = 0.0
        if view is UICollectionView {
            
            let collectionView = view as! UICollectionView
            widthConstant = Double(collectionView.contentInset.left + collectionView.contentInset.right)
        }
        else if view is UITableView {
            let tableView = view as! UITableView
            widthConstant = Double(tableView.contentInset.left + tableView.contentInset.right)
        }
        
        let viewDict = ["self": self]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[self]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
        view.addConstraints([
            NSLayoutConstraint.init(item: self, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: CGFloat(-widthConstant)),
            NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0)
            ])
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[self]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        self.addSubview(self.contentView)
        self.addGestureRecognizer(self.tapGesture)
        
    }
    
    /// 移除所有子控件及其约束
    func resetSubviews() {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        titleLabel.removeFromSuperview()
        detailLabel.removeFromSuperview()
        imageView.removeFromSuperview()
        customView?.removeFromSuperview()
        reloadButton.removeFromSuperview()
        self.removeAllConstraints()
    }
    
    /// 设置tap手势
    ////////////////////////////////////////////////////////////////////////
    func tapGestureRecognizer(_ tapBlock: @escaping (UITapGestureRecognizer) -> Swift.Void) {
     
        self.tapGestureRecognizerBlock = tapBlock
    }
    

    ////////////////////////////////////////////////////////////////////////
    class func show(to view: UIView, animated: Bool) -> NoDataPlaceholderView {
        let view = NoDataPlaceholderView.init(view)
        view.showAnimated(animated)
        return view
    }
    
    private func showAnimated(_ animated: Bool) {
        
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.contentView.alpha = 1.0
        }
    }
    
    /// 点击刷新按钮时处理事件
    @objc private func clickReloadBtn(_ btn: UIButton) {
        let name = "xy_clickReloadBtn:"
        let sel = NSSelectorFromString(name)
        var superV = self.superview
        while superV != nil {
            if superV is UIScrollView {
                superV!.perform(sel, with: btn)
                superV = nil
            }
            else {
                superV = superV?.superview
            }
        }
        
        
    }
    
    @objc private func tapGestureOnSelf(_ tap: UITapGestureRecognizer) {
        if self.tapGestureRecognizerBlock != nil {
            self.tapGestureRecognizerBlock!(tap)
        }
    }

    // MARK: - Constraints
    override func updateConstraints() {
        
        removeAllConstraints()
        // contentView 与 父视图 保持一致, 根据子控件的高度而改变
        let contentViewConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint.init(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint.init(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            ]
        addConstraints(contentViewConstraints)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(contentViewHorizontalSpace)-[contentView]-(contentViewHorizontalSpace)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["contentViewHorizontalSpace": contentViewHorizontalSpace], views: ["contentView": contentView]))
        
        
        // 需要调整self 相对父控件顶部和左侧 的偏移量
        if let selfTopConstraint = getSelfTopConstraint(),
            let selfBottomConstraint = getSelfBottomConstraint(),
            let selfLeftConstraint = getSelfLeftConstraint(),
            let selfRightConstraint = getSelfRightConstraint()
        {
            selfTopConstraint.constant = contentOffsetY
            selfBottomConstraint.constant = contentOffsetY
            selfLeftConstraint.constant = contentOffsetX
            selfRightConstraint.constant = contentOffsetX
        }

        
        // 若有customView 则 让其与contentView的约束相同
        if let customView = customView {
            self.contentView.addSubview(customView)
            
            let viewDict: [String: UIView] = ["customView": customView]
            
            let constraints1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[customView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict)
            let constraints2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[customView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict)
            contentView.addConstraints(constraints1)
            contentView.addConstraints(constraints2)
        }
        else {
            
            // 无customView
            var width : CGFloat = frame.size.width
            if width == 0 {
                width = UIScreen.main.bounds.width
            }
            
            // contentView的子控件横向间距  四舍五入
            let horizontalSpace = roundf(Float(width / NoDataPlaceholderHorizontalSpaceRatioValue))
            // contentView的子控件之间的垂直间距，默认为10.0
            let globalverticalSpace = self.globalVerticalSpace
            
            var subviewKeyArray = [String]()
            var subviewDict = [String: UIView]()
            var metrics = ["horizontalSpace": horizontalSpace] as [String : Any]
            
            // 设置imageView水平约束
            if canShowImage() {
                self.contentView.addSubview(self.imageView)
                subviewKeyArray.append("imageView")
                subviewDict[subviewKeyArray.last!] = imageView
                
                var imageLeftSpace = horizontalSpace
                var imageRightSpace = horizontalSpace
                if canChangeInsets(insets: self.imageEdgeInsets) {
                    
                    imageLeftSpace = Float(self.imageEdgeInsets.left)
                    imageRightSpace = Float(self.imageEdgeInsets.right)
                    let imageMetrics = ["imageLeftSpace": imageLeftSpace, "imageRightSpace": imageRightSpace]
                    // 合并字典
                    for d in imageMetrics {
                        metrics[d.key] = imageMetrics[d.key]
                    }
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(imageLeftSpace@999)-[imageView]-(imageRightSpace@999)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
                    
                }
                else {
                    let imageViewCenterX = NSLayoutConstraint.init(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
                    self.contentView.addConstraint(imageViewCenterX)
                }
                if (self.imageViewSize.width > 0.0 && self.imageViewSize.height > 0.0) {
                    self.contentView.addConstraints([
                        NSLayoutConstraint.init(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.imageViewSize.width),
                        NSLayoutConstraint.init(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.imageViewSize.height)
                        ])
                }
                
            } else {
                imageView .removeFromSuperview()
            }
            
            // 根据title是否可以显示，设置titleLable的水平约束
            if (canShowTitle()) {
                self.contentView.addSubview(self.titleLabel)
                var titleLeftSpace = horizontalSpace
                var titleRightSpace = horizontalSpace
                if (canChangeInsets(insets: self.titleEdgeInsets)) {
                    titleLeftSpace = Float(self.titleEdgeInsets.left)
                    titleRightSpace = Float(self.titleEdgeInsets.right)
                }
                let titleMetrics = ["titleLeftSpace": titleLeftSpace, "titleRightSpace": titleRightSpace]
                for d in titleMetrics {
                    metrics[d.key] = titleMetrics[d.key]
                }
                subviewKeyArray.append("titleLabel")
                subviewDict[subviewKeyArray.last!] = self.titleLabel
                
                self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(titleLeftSpace@999)-[titleLabel(>=0)]-(titleRightSpace@999)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
                
            } else {
                // 不显示就移除
                titleLabel.removeFromSuperview()
                
            }
            
            // 根据是否可以显示detail, 设置detailLabel水平约束
            if (self.canShowDetail()) {
                self.contentView.addSubview(self.detailLabel)
                
                var detailLeftSpace = horizontalSpace
                var detailRightSpace = horizontalSpace
                if (self.canChangeInsets(insets: self.detailEdgeInsets)) {
                    detailLeftSpace = Float(self.detailEdgeInsets.left)
                    detailRightSpace = Float(self.detailEdgeInsets.right)
                }
                let detailMetrics = ["detailLeftSpace": detailLeftSpace, "detailRightSpace": detailRightSpace]
                for d in detailMetrics {
                    metrics[d.key] = detailMetrics[d.key]
                }
                subviewKeyArray.append("detailLabel")
                subviewDict[subviewKeyArray.last!] = detailLabel
                self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(detailLeftSpace@999)-[detailLabel(>=0)]-(detailRightSpace@999)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
          
            } else {
                // 不显示就移除
                detailLabel.removeFromSuperview()
                
            }
            
            // 根据reloadButton是否能显示，设置其水平约束
            if (self.canShowReloadButton()) {
                self.contentView.addSubview(self.reloadButton)
                var buttonLeftSpace = horizontalSpace
                var buttonRightSpace = horizontalSpace
                if (self.canChangeInsets(insets: self.buttonEdgeInsets)) {
                    buttonLeftSpace = Float(self.buttonEdgeInsets.left)
                    buttonRightSpace = Float(self.buttonEdgeInsets.right)
                }
                let buttonMetrics = ["buttonLeftSpace": buttonLeftSpace, "buttonRightSpace": buttonRightSpace]
                for d in buttonMetrics {
                    metrics[d.key] = buttonMetrics[d.key]
                }
                
                subviewKeyArray.append("reloadButton")
                subviewDict[subviewKeyArray.last!] = reloadButton
                
                self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(buttonLeftSpace@999)-[reloadButton(>=0)]-(buttonRightSpace@999)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
            } else {
                // 不显示就移除
                reloadButton.removeFromSuperview()
            }
            
            // 设置垂直约束
            var verticalFormat = String()
            // 拼接字符串，添加每个控件垂直边缘之间的约束值, 默认为globalVerticalSpace 11.0，如果设置了子控件的contentEdgeInsets,则verticalSpace无效
            var previousView : UIView?
            for viewName in subviewKeyArray {
                var topSpace = globalverticalSpace
                guard let view = subviewDict[viewName] else {
                    continue
                }
                // 拼接间距值
                if (self.canChangeInsets(insets: view.noDataPlaceholderViewContentEdgeInsets)) {
                    topSpace = view.noDataPlaceholderViewContentEdgeInsets.top
                }
                if let previousView = previousView {
                    if (self.canChangeInsets(insets: previousView.noDataPlaceholderViewContentEdgeInsets)) {
                        topSpace += previousView.noDataPlaceholderViewContentEdgeInsets.bottom
                    }
                }
                
                verticalFormat += "-(\(topSpace)@999)-[\(viewName)]"
                
                if (viewName == subviewKeyArray.last) {
                    // 最后一个控件把距离父控件底部的约束值也加上
                    verticalFormat += "-(\(view.noDataPlaceholderViewContentEdgeInsets.bottom)@999)-"
                }
                
                previousView = view;
            }
            
            previousView = nil;
            // 向contentView分配垂直约束
            if (verticalFormat.count > 0) {
                self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|\(verticalFormat)|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
            }
        }
        
        
        
        super.updateConstraints()
    }
    
    fileprivate func removeAllConstraints() {
        superview?.removeConstraints(constraints)
        removeConstraints(constraints)
        contentView.removeConstraints(contentView.constraints)
    }
    
    func getSelfTopConstraint() -> NSLayoutConstraint? {
        let superViewConstraints = superview?.constraints
        if superViewConstraints?.count == 0 {
            return nil
        }
       
        for constraint in superViewConstraints! {
            if constraint.firstItem as! NSObject == self && constraint.firstAttribute == .top {
                return constraint
            }
        }
        
        return nil
    }
    
    func getSelfBottomConstraint() -> NSLayoutConstraint? {
        let superViewConstraints = superview?.constraints
        if superViewConstraints?.count == 0 {
            return nil
        }
        
        for constraint in superViewConstraints! {
            if constraint.secondItem as! NSObject == self && constraint.firstAttribute == .bottom {
                return constraint
            }
        }
        
        return nil
    }
    
    func getSelfLeftConstraint() -> NSLayoutConstraint? {
        let superViewConstraints = superview?.constraints
        if superViewConstraints?.count == 0 {
            return nil
        }
        
        for constraint in superViewConstraints! {
            if constraint.firstItem as! NSObject == self && constraint.firstAttribute == .leading {
                return constraint
            }
        }
        
        return nil
    }
    
    func getSelfRightConstraint() -> NSLayoutConstraint? {
        let superViewConstraints = superview?.constraints
        if superViewConstraints?.count == 0 {
            return nil
        }
        
        for constraint in superViewConstraints! {
            if constraint.secondItem as! NSObject == self && constraint.firstAttribute == .trailing {
                return constraint
            }
        }
        
        return nil
    }
    
    // MARK: - Others
    func canShowImage() -> Bool {
        return (imageView.image != nil) //&& (imageView.superview != nil)
    }
    
    func canShowTitle() -> Bool {
        return (titleLabel.text != nil) //&& (titleLabel.superview != nil)
    }
  
    func canShowDetail() -> Bool {
        return (detailLabel.text != nil) //&& (detailLabel.superview != nil)
    }
    
    func canShowReloadButton() -> Bool {
        if (reloadButton.title(for: .normal) != nil) ||
            (reloadButton.image(for: .normal) != nil) ||
            (reloadButton.attributedTitle(for: .normal) != nil) {
            return true//reloadButton.superview != nil
        }
        return false
    }
    
    func canChangeInsets(insets: UIEdgeInsets) -> Bool {
        return UIEdgeInsetsEqualToEdgeInsets(insets, .zero) != false
    }

    // MARK: - Touchs
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let touchView = super.hitTest(point, with: event) else {
            return nil
        }
        
        // 如果hitView是UIControl或其子类初始化的，就返回此hitView的实例
        if touchView is UIControl {
            return touchView
        }
        // 如果hitView是contentView或customView, 就返回此实例
        if touchView.isEqual(contentView) {
            return touchView
        }
        if let customView = customView {
            if touchView.isEqual(customView) {
                return touchView
            }
        }
        
        return nil;
    }

}

