//
//  XYEmptyData.swift
//  XYEmptyDataView
//  https://github.com/tuxi/XYEmptyDataView
//  Created by xiaoyuan on 2018/1/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc public protocol XYEmptyDataDelegate: NSObjectProtocol {
    
    
    /// 是否应该淡入淡出，default is YES
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(shouldFadeInOnDisplay scrollView: UIScrollView) -> Bool
    
    
    /// 是否应显示emptyDataView, 默认YES
    /// @return 如果当前无数据则应显示emptyDataView
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(shouldDisplay scrollView: UIScrollView) -> Bool
    
    
    /// 当前所在页面的数据源itemCount>0时，是否应该实现emptyDataView，default return NO
    /// @return 如果需要强制显示emptyDataView，return YES即可
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(shouldBeForcedToDisplay scrollView: UIScrollView) -> Bool
    
    
    /// 当emptyDataView即将显示的回调
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(willAppear scrollView: UIScrollView)
    
    
    /// 当emptyDataView完全显示的回调
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(didAppear scrollView: UIScrollView)
    
    
    /// 当emptyDataView即将消失的回调
    @objc @available(iOS 2.0, *)
    optional  func emptyDataView(willDisappear scrollView: UIScrollView)
    
    
    /// 当emptyDataView完全消失的回调
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(didDisappear scrollView: UIScrollView)
    
    
    /// emptyDataView是否可以响应事件，默认YES
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(shouldAllowResponseEvent scrollView: UIScrollView) -> Bool
    
    
    /// emptyDataView是否可以滚动，默认YES
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(shouldAllowScroll scrollView: UIScrollView) -> Bool
    
    
    @objc @available(iOS 3.2, *)
    optional func emptyDataView(_ scrollView: UIScrollView, didTapOnContentView tap: UITapGestureRecognizer)
    
    
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(_ scrollView: UIScrollView, didClickReload button: UIButton)
    
    
    /// emptyDataView各子控件之间垂直的间距，默认为11
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(contentSubviewsGlobalVerticalSpaceForEmptyDataView scrollView: UIScrollView) -> CGFloat
    
    
    /// emptyDataView 的 contentView上下左右间距
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(contentEdgeInsetsForEmptyDataView scrollView: UIScrollView) -> UIEdgeInsets
    
    
    /// imageView的size, 有的时候图片本身太大，导致imageView的尺寸并不是我们想要的，可以通过此方法设置, 当为CGSizeZero时不设置,默认为CGSizeZero
    @objc @available(iOS 2.0, *)
    optional func emptyDataView(imageViewSizeForEmptyDataView scrollView: UIScrollView) -> CGSize
    
    /// 自定义空视图view
    @objc @available(iOS 2.0, *)
    optional func customView(forEmptyDataView scrollView: UIScrollView) -> UIView?
}


extension UIScrollView: UIGestureRecognizerDelegate {
    
    /// 用于关联对象的keys
    private struct XYEmptyDataKeys {
        static var delegate = "com.alpface.XYEmptyData.delete"
        static var loading = "com.alpface.XYEmptyData.loading"
        
        static var emptyDataView = "com.alpface.XYEmptyData.emptyDataView"
        static var registerEmptyDataView = "com.alpface.XYEmptyData.registerEemptyDataView"
        
        static var config = "com.alpface.XYEmptyData.config"
    }
    
    /// 存放一些空数据的结果
    public struct EmptyData {
        public enum Alignment {
            case center(offset: CGFloat = 0)
            case top
            case bottom
        }
        
        public var alignment: Alignment
        public var contentEdgeInsets: UIEdgeInsets = .zero
        public var customEmptyDataView: (() -> UIView)?
        public var xy_textLabelBlock: ((UILabel) -> Swift.Void)?
        public var xy_detailTextLabelBlock: ((UILabel) -> Swift.Void)?
        public var xy_imageViewBlock: ((UIImageView) -> Swift.Void)?
        public var xy_reloadButtonBlock: ((UIButton) -> Swift.Void)?
        public var xy_textEdgeInsets: UIEdgeInsets = .zero
        public var xy_imageEdgeInsets: UIEdgeInsets = .zero
        public var xy_detailEdgeInsets: UIEdgeInsets = .zero
        public var xy_buttonEdgeInsets: UIEdgeInsets = .zero
        public var emptyDataViewBackgroundColor: UIColor?
        /// emptyDataView中contentView的背景颜色
        public var emptyDataViewContentBackgroundColor: UIColor?
    }
    
    weak open var emptyDataDelegate: XYEmptyDataDelegate? {
        get {
            let delegateCon = objc_getAssociatedObject(self, &XYEmptyDataKeys.delegate) as? _WeakObjectContainer
            if let delegate = delegateCon?.weakObject as? XYEmptyDataDelegate {
                return delegate
            }
            return nil
        }
        set {
            if let oldDelegate = emptyDataDelegate {
                if oldDelegate.isEqual(newValue) {
                    return
                }
            }
            
            
            if newValue == nil || xy_emptyDataViewCanDisplay() == false {
                xy_removeEmptyDataView()
                return
            }
            objc_setAssociatedObject(self, &XYEmptyDataKeys.delegate, _WeakObjectContainer(weakObject: newValue as AnyObject), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            registerEmptyDataView()
        }
    }
    
    open var emptyData: EmptyData? {
        get {
            return objc_getAssociatedObject(self, &XYEmptyDataKeys.config) as? EmptyData
        }
        set {
            objc_setAssociatedObject(self, &XYEmptyDataKeys.config, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            xy_reloadEmptyDataView()
        }
    }
    
    open var xy_loading: Bool {
        get {
            if let obj = objc_getAssociatedObject(self, &XYEmptyDataKeys.loading) as? NSNumber {
                return obj.boolValue
            }
            return false
        }
        set {
            if xy_loading == newValue  {
                return
            }
            objc_setAssociatedObject(self, &XYEmptyDataKeys.loading, NSNumber.init(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            xy_reloadEmptyDataView()
        }
    }
    
    fileprivate var emptyDataView: XYEmptyDataView? {
        get {
            if let view = objc_getAssociatedObject(self, &XYEmptyDataKeys.emptyDataView) as? XYEmptyDataView {
                return view
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &XYEmptyDataKeys.emptyDataView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 初始化空数据视图
    fileprivate func setupEmptyDataView() {
        var view = self.emptyDataView
        if view == nil {
            view = XYEmptyDataView.show(withView: self, animated: xy_emptyDataViewShouldFadeInOnDisplay())
            view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view?.isHidden = true
            view?.tapGesture.delegate = self
            view?.tapGestureRecognizer({[weak self] (tap) in
                self?.xy_didTapContentView(tap: tap)
            })
            
            self.emptyDataView = view
        }
    }


    
    fileprivate func registerEmptyDataView() {
        
        var num = objc_getAssociatedObject(self, &XYEmptyDataKeys.registerEmptyDataView) as? NSNumber
        
        if num == nil || num?.boolValue == false {
            if self.xy_emptyDataViewCanDisplay() == false {
                self.xy_removeEmptyDataView()
                num = NSNumber(value: false)
            }
            else {
                num = NSNumber(value: true)
                setupEmptyDataView()
                let executeBlock = { (view: AnyObject?, command: Selector, param1: AnyObject?, param2: AnyObject?) in
                    
                }
                
                // 对reloadData方法的实现进行处理, 为加载reloadData时注入额外的实现
                Swizzler.swizzleSelector(NSSelectorFromString("reloadData"),
                                         withSelector: #selector(self.xy_reloadEmptyDataView),
                                         for: self.classForCoder,
                                         name: "reloadData",
                                         block: executeBlock)
                if self is UITableView {
                    Swizzler.swizzleSelector(NSSelectorFromString("endUpdates"),
                                             withSelector: #selector(self.xy_reloadEmptyDataView),
                                             for: self.classForCoder,
                                             name: "endUpdates",
                                             block: executeBlock)
                }
                objc_setAssociatedObject(self, &XYEmptyDataKeys.registerEmptyDataView, num, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
        }

    }
    
    
    /// 刷新emptyDataView, 当执行tableView的readData、endUpdates或者CollectionView的readData时会调用此方法
    ////////////////////////////////////////////////////////////////////////
    @objc open func xy_reloadEmptyDataView() {
        if xy_emptyDataViewCanDisplay() == false {
            return
        }
        
        if let emptyData = self.emptyData, (xy_emptyDataViewShouldDisplay() == true &&
            xy_itemCount() <= 0) ||
            xy_emptyDataViewShouldBeForcedToDisplay() == true {
            
            // 通知代理即将显示
            xy_emptyDataViewWillAppear()
            
            var noDataView = self.emptyDataView
            if  noDataView == nil {
                setupEmptyDataView()
                noDataView = self.emptyDataView
            }
            guard let emptyDataView = emptyDataView else {
                return
            }
            
            // 重置视图及其约束
            emptyDataView.resetSubviews()
            emptyDataView.alignment = emptyData.alignment
            
            if let customView = xy_emptyDataViewCustomView() {
                emptyDataView.customView = customView
            } else {
                // customView为nil时，则通过block回到获取子控件 设置
                if let block = emptyData.xy_textLabelBlock  {
                    block(emptyDataView.titleLabel)
                }
                if let block = emptyData.xy_detailTextLabelBlock {
                    block(emptyDataView.detailLabel)
                }
                
                if let block = emptyData.xy_imageViewBlock {
                    block(emptyDataView.imageView)
                }
                if let block = emptyData.xy_reloadButtonBlock {
                    block(emptyDataView.reloadButton)
                }
                
                // 设置子控件之间的边距
                emptyDataView.titleEdgeInsets = emptyData.xy_textEdgeInsets
                emptyDataView.detailEdgeInsets = emptyData.xy_detailEdgeInsets
                emptyDataView.imageEdgeInsets = emptyData.xy_imageEdgeInsets
                emptyDataView.buttonEdgeInsets = emptyData.xy_buttonEdgeInsets
                // 设置emptyDataView子控件垂直间的间距
                emptyDataView.globalVerticalSpace = xy_emptyDataViewGlobalVerticalSpace()
                
            }
            
            emptyDataView.contentEdgeInsets = emptyData.contentEdgeInsets
            emptyDataView.backgroundColor = xy_emptyDataViewBackgroundColor()
            emptyDataView.contentView.backgroundColor = xy_emptyDataViewContentBackgroundColor()
            emptyDataView.isHidden = false;
            emptyDataView.clipsToBounds = true
            emptyDataView.imageViewSize = xy_emptyDataViewImageViewSize()
            
            emptyDataView.isUserInteractionEnabled = xy_emptyDataViewIsAllowedResponseEvent()
            
            emptyDataView.setNeedsUpdateConstraints()
            
            // 此方法会先检查动画当前是否启用，然后禁止动画，执行block块语句
            UIView.performWithoutAnimation {
                emptyDataView.layoutIfNeeded()
            }
          self.isScrollEnabled = xy_emptyDataViewIsAllowedScroll()
            // 通知代理完全显示
            xy_emptyDataViewDidAppear()
            
        } else {
            xy_removeEmptyDataView()
        }
        
        
        let originalSelector = NSSelectorFromString("reloadData")
        callOriginalFunctionAndSwizzledBlocks(originalSelector: originalSelector)
        
    }
    
    @objc func callOriginalFunctionAndSwizzledBlocks(originalSelector: Selector) {
        if let originalMethod = class_getInstanceMethod(type(of: self), originalSelector),
            let swizzle = Swizzler.swizzles[originalMethod] {
            typealias MyCFunction = @convention(c) (AnyObject, Selector) -> Void
            let curriedImplementation = unsafeBitCast(swizzle.originalMethod, to: MyCFunction.self)
            curriedImplementation(self, originalSelector)
            
            for (_, block) in swizzle.blocks {
                block(self, swizzle.selector, nil, nil)
            }
        }
    }
    
    private func xy_removeEmptyDataView() {
        // 通知代理即将消失
        self.xy_emptyDataViewWillDisappear()
        if let nView = self.emptyDataView {
            nView.resetSubviews()
            nView.removeFromSuperview()
            self.emptyDataView = nil
            
        }
        self.isScrollEnabled = true
        
        // 通知代理完全消失
        self.xy_emptyDataViewDidDisappear()
    }
    
    private func xy_emptyDataViewBackgroundColor() -> UIColor {
        guard let color = self.emptyData?.emptyDataViewBackgroundColor else {
            return UIColor.clear
        }
        return color
    }
    
    
    private func xy_emptyDataViewContentBackgroundColor() -> UIColor {
        guard let color = self.emptyData?.emptyDataViewContentBackgroundColor else {
            return UIColor.clear
        }
        return color
    }
    
    // 是否符合显示
    private func xy_emptyDataViewCanDisplay() -> Bool {
        if  self is UITableView || self is UICollectionView {
            return true
        }
        return false
    }
    
    private func xy_itemCount() -> Int {
        var itemCount = 0
        
        let selectorName = "dataSource"
        
        if self.responds(to: NSSelectorFromString(selectorName)) == false {
            return itemCount
        }
        
        // UITableView
        if (self is UITableView) {
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
        
        return itemCount;
    }
    
    /// 是否需要淡入淡出
    private func xy_emptyDataViewShouldFadeInOnDisplay() -> Bool {
        guard let del = self.emptyDataDelegate else {
            return true
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(shouldFadeInOnDisplay:))) {
            return del.emptyDataView!(shouldFadeInOnDisplay: self)
        }
        
        return true
    }
    
    /// 是否应该显示
    private func xy_emptyDataViewShouldDisplay() -> Bool {
        guard let del = self.emptyDataDelegate else {
            return true
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(shouldDisplay:))) {
            return del.emptyDataView!(shouldDisplay: self)
        }
        return true
    }
    
    /// 是否应该强制显示,默认不需要的
    private func xy_emptyDataViewShouldBeForcedToDisplay() -> Bool {
        guard let del = self.emptyDataDelegate else {
            return false
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(shouldBeForcedToDisplay:))) {
            return del.emptyDataView!(shouldBeForcedToDisplay: self)
        }
        return false
    }

    /// 即将显示空数据时调用
    private func xy_emptyDataViewWillAppear() {
        guard let del = self.emptyDataDelegate else {
            return
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(willAppear:))) {
             del.emptyDataView!(willAppear: self)
        }
        
    }

    /// 是否允许响应事件
    private func xy_emptyDataViewIsAllowedResponseEvent() -> Bool {
        guard let del = self.emptyDataDelegate else {
            return true
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(shouldAllowResponseEvent:))) {
            return del.emptyDataView!(shouldAllowResponseEvent: self)
        }
        return true
    }
    
    /// 是否运行滚动
    private func xy_emptyDataViewIsAllowedScroll() -> Bool {
        guard let del = self.emptyDataDelegate else {
            return true
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(shouldAllowScroll:))) {
            return del.emptyDataView!(shouldAllowScroll: self)
            
        }
        return true
    }
   
    /// 已经显示空数据时调用
    private func xy_emptyDataViewDidAppear() {
        // 这里以UITableView为例: 当调用原reloadData后，tableView的contentSize会被重置为所有cell的高度，而显示空数据时，tableView并没有数据，所以导致contentSize被重置为zero，导致空视图超出tableView的高度时依旧无法滚动
        DispatchQueue.main.async {
            let contentSize = self.contentSize
            self.contentSize = CGSize(width: contentSize.width == 0 ? self.emptyDataView?.frame.size.width ?? 0 : 0, height: (self.emptyDataView?.frame.size.height ?? 0))
        }
        guard let del = self.emptyDataDelegate else {
            return
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(didAppear:))) {
            del.emptyDataView!(didAppear: self)
        }
    }

    /// 空数据即将消失时调用
    private func xy_emptyDataViewWillDisappear() {
        guard let del = self.emptyDataDelegate else {
            return
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(willDisappear:))) {
            del.emptyDataView!(willDisappear: self)
        }
    }
   
    /// 空数据已经消失时调用
    private func xy_emptyDataViewDidDisappear() {
        guard let del = self.emptyDataDelegate else {
            return
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(didDisappear:))) {
            del.emptyDataView!(didDisappear: self)
        }
    }

    /// 当自定义空数据视图时调用
    private func xy_emptyDataViewCustomView() -> UIView? {
        var view: UIView?
        if let del = self.emptyDataDelegate {
            if del.responds(to: #selector(XYEmptyDataDelegate.customView(forEmptyDataView:))) {
                return del.customView!(forEmptyDataView: self)
            }
        }
        if let customEmptyDataView = self.emptyData?.customEmptyDataView {
            view = customEmptyDataView()
        }
        return view
    }
    
    /// 获取子控件垂直间距时调用, 默认为10.0
    private func xy_emptyDataViewGlobalVerticalSpace() -> CGFloat {
        guard let del = self.emptyDataDelegate else {
            return 10.0
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(contentSubviewsGlobalVerticalSpaceForEmptyDataView:))) {
            return del.emptyDataView!(contentSubviewsGlobalVerticalSpaceForEmptyDataView: self)
        }
        return 10.0;
    }
    
    /// 获取空数据视图上ImageView的固定尺寸
    private func xy_emptyDataViewImageViewSize() -> CGSize {
        guard let del = self.emptyDataDelegate else {
            return CGSize.zero
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(imageViewSizeForEmptyDataView:))) {
            return del.emptyDataView!(imageViewSizeForEmptyDataView: self)
        }
        return CGSize.zero
    }
    
    /// 点击空数据视图的 contentView的回调
    private func xy_didTapContentView(tap: UITapGestureRecognizer) -> Void {
        guard let del = self.emptyDataDelegate else {
            return
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(_:didTapOnContentView:))) {
            del.emptyDataView!(self, didTapOnContentView: tap)
        }
    }
    
    /// 点击空数据视图的 reload的回调
    @objc fileprivate func xy_clickReloadBtn(btn: UIButton) {
        guard let del = self.emptyDataDelegate else {
            return
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(_:didClickReload:))) {
            del.emptyDataView!(self, didClickReload: btn)
        }
    }

    // MARK: - UIGestureRecognizerDelegate
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view?.isEqual(self.emptyDataView) == true {
            return self.xy_emptyDataViewIsAllowedResponseEvent()
        }
        
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
        
    }
    
}




fileprivate let EmptyDataViewHorizontalSpaceRatioValue: CGFloat = 16.0

fileprivate class _WeakObjectContainer : NSObject {
    
    
    weak open var weakObject: AnyObject?
    
    
    public init(weakObject: AnyObject) {
        self.weakObject = weakObject
    }
}



extension UIView {
    
    struct XYEmptyDataKeys {
        static var emptyDataViewContentEdgeInsets = "com.alpface.XYEmptyData.emptyDataViewContentEdgeInsets"
    }
    open var emptyDataViewContentEdgeInsets: UIEdgeInsets {
        get {
            if let obj = objc_getAssociatedObject(self, XYEmptyDataKeys.emptyDataViewContentEdgeInsets) as? NSValue {
                return obj.uiEdgeInsetsValue
            }
            return UIEdgeInsets.zero
        }
        set {
            let value : NSValue = NSValue.init(uiEdgeInsets: newValue)
            
            objc_setAssociatedObject(self, &XYEmptyDataKeys.emptyDataViewContentEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

fileprivate class XYEmptyDataView : UIView {
    
    
    // MARK: - Views
    /// 内容视图
    lazy var contentView: UIView = {
        let contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        contentView.alpha = 0.0
        return contentView
    }()
    
    /// 标题`label`
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
    
    /// 详情`label`
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
    
    /// 图片
    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    /// 刷新按钮
    lazy open var reloadButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(XYEmptyDataView.clickReloadBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 自定义视图
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
    
    // MARK: - Properties
    /// 点按手势
    lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(XYEmptyDataView.tapGestureOnSelf(_:)))
        return tap
    }()
    
    var contentEdgeInsets: UIEdgeInsets = .zero
    
    /** 所有子控件之间垂直间距 */
    var globalVerticalSpace: CGFloat = 10.0
    
    /** 各子控件之间的边距，若设置此边距则 */
    var titleEdgeInsets: UIEdgeInsets {
        get {
            return titleLabel.emptyDataViewContentEdgeInsets
        }
        set {
            self.titleLabel.emptyDataViewContentEdgeInsets = newValue
        }
    }
    
    var imageEdgeInsets: UIEdgeInsets {
        get {
            return imageView.emptyDataViewContentEdgeInsets
        }
        set {
            self.imageView.emptyDataViewContentEdgeInsets = newValue
        }
    }
    
    var detailEdgeInsets: UIEdgeInsets {
        get {
            return detailLabel.emptyDataViewContentEdgeInsets
        }
        set {
            self.detailLabel.emptyDataViewContentEdgeInsets = newValue
        }
    }
    
    var buttonEdgeInsets: UIEdgeInsets {
        get {
            return reloadButton.emptyDataViewContentEdgeInsets
        }
        set {
            self.reloadButton.emptyDataViewContentEdgeInsets = newValue
        }
    }
    
    var alignment: UIScrollView.EmptyData.Alignment = .center(offset: 0)
    
    /** imageView的size, 有的时候图片本身太大，导致imageView的尺寸并不是我们想要的，可以通过此方法设置, 当为CGSizeZero时不设置,默认为CGSizeZero */
    var imageViewSize: CGSize = .zero
    
    /** tap手势回调block */
    var tapGestureRecognizerBlock: ((UITapGestureRecognizer) -> Swift.Void)?
    
    /// 添加在父控件上的约束
    private var superConstraints = [NSLayoutConstraint]()
    /// 添加在`contentView`控件上的约束
    private var contentViewConstraints = [NSLayoutConstraint]()
    
    convenience init(_ view: UIView) {
        self.init(frame: view.bounds)
        show(withView: view)
    }
    
    private func show(withView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if self.superview == nil {
            if view is UITableView || view is UICollectionView {
                if view.subviews.count > 1 {
                    view.insertSubview(self, at: 0)
                }
                else {
                    view.addSubview(self)
                }
            }
        }
       
        let superview: UIView = view
        superview.removeConstraints(superConstraints)
        superConstraints.removeAll()
        
        let left = scrollViewContentInset.left
        let top = scrollViewContentInset.top
        let right = scrollViewContentInset.right
        let bottom = scrollViewContentInset.bottom
        let metrics: [String: Any] = ["left": left, "right": right, "top": top, "bottom": bottom]
        let hFormat = "H:|-(left)-[self]-(right)-|"
        let vFormat = "V:|-(left)-[self]-(right)-|"
        let viewDict = ["self": self]
        
        superConstraints.append(contentsOf: [
            hFormat,
            vFormat
        ]
        .flatMap {
            NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: metrics, views: viewDict)
        })
        
        superConstraints.append(contentsOf: [
            widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -(left + right)),
            heightAnchor.constraint(equalTo: superview.heightAnchor, constant: -(top + bottom))
        ])
        superview.addConstraints(superConstraints)

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
        contentView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        titleLabel.removeFromSuperview()
        detailLabel.removeFromSuperview()
        imageView.removeFromSuperview()
        customView?.removeFromSuperview()
        customView = nil
        reloadButton.removeFromSuperview()
        self.removeAllConstraints()
    }
    
    /// 设置tap手势
    ////////////////////////////////////////////////////////////////////////
    func tapGestureRecognizer(_ tapBlock: @escaping (UITapGestureRecognizer) -> Swift.Void) {
     
        self.tapGestureRecognizerBlock = tapBlock
    }
    

    ////////////////////////////////////////////////////////////////////////
    class func show(withView view: UIView, animated: Bool) -> XYEmptyDataView {
        let view = XYEmptyDataView.init(view)
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
        let sel = #selector(UIScrollView.xy_clickReloadBtn(btn:))
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
        updateSuperConstraints()
        updateContentViewConstraints()
        
        // 若有customView 则 让其与contentView的约束相同
        if let customView = customView {
            self.contentView.addSubview(customView)
            
            let viewDict: [String: UIView] = ["customView": customView]
            
            let constraints1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[customView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDict)
            let constraints2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[customView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDict)
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
            let horizontalSpace = roundf(Float(width / EmptyDataViewHorizontalSpaceRatioValue))
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
                    contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(imageLeftSpace@999)-[imageView]-(imageRightSpace@999)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
                    
                }
                else {
                    let imageViewCenterX = NSLayoutConstraint.init(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
                    self.contentView.addConstraint(imageViewCenterX)
                }
                if (self.imageViewSize.width > 0.0 && self.imageViewSize.height > 0.0) {
                    self.contentView.addConstraints([
                        NSLayoutConstraint.init(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.imageViewSize.width),
                        NSLayoutConstraint.init(item: self.imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.imageViewSize.height)
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
                
                self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(titleLeftSpace@999)-[titleLabel(>=0)]-(titleRightSpace@999)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
                
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
                self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(detailLeftSpace@999)-[detailLabel(>=0)]-(detailRightSpace@999)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
          
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
                
                self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(buttonLeftSpace@999)-[reloadButton(>=0)]-(buttonRightSpace@999)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
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
                if (self.canChangeInsets(insets: view.emptyDataViewContentEdgeInsets)) {
                    topSpace = view.emptyDataViewContentEdgeInsets.top
                }
                if let previousView = previousView {
                    if (self.canChangeInsets(insets: previousView.emptyDataViewContentEdgeInsets)) {
                        topSpace += previousView.emptyDataViewContentEdgeInsets.bottom
                    }
                }
                
                verticalFormat += "-(\(topSpace)@999)-[\(viewName)]"
                
                if (viewName == subviewKeyArray.last) {
                    // 最后一个控件把距离父控件底部的约束值也加上
                    verticalFormat += "-(\(view.emptyDataViewContentEdgeInsets.bottom)@999)-"
                }
                
                previousView = view;
            }
            
            previousView = nil;
            // 向contentView分配垂直约束
            if (verticalFormat.count > 0) {
                self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|\(verticalFormat)|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
            }
        }
        
        
        
        super.updateConstraints()
    }
    
    /// 更新自身的约束到父视图
    private func updateSuperConstraints() {
        guard superConstraints.count > 0 else {
            return
        }
        
        superConstraints.forEach {
            switch $0.firstAttribute {
            case .top:
                $0.constant = scrollViewContentInset.top
            case .bottom:
                $0.constant = scrollViewContentInset.bottom
            case .left, .leading:
                $0.constant = scrollViewContentInset.left
            case .right, .trailing:
                $0.constant = scrollViewContentInset.right
            default:
                break
            }
        }
    }
    
    private func updateContentViewConstraints() {
        removeConstraints(contentViewConstraints)
        contentViewConstraints.removeAll()
        
        let viewDict = ["contentView": contentView]
        let metrics: [String: Any] = ["left": contentEdgeInsets.left, "right": contentEdgeInsets.right, "top": contentEdgeInsets.top, "bottom": contentEdgeInsets.bottom]
        let hFormat = "H:|-(left)-[contentView]-(right)-|"
        var vFormat = "V:|-(top)-[self]-(bottom)-|"

        switch alignment {
        case .top:
            vFormat = "V:|-(top)-[contentView]-(<=bottom)-|"
        case .bottom:
            vFormat = "V:|-(>=top)-[contentView]-(bottom)-|"
        case .center(let offset):
            vFormat = "V:|-(>=top)-[contentView]-(<=bottom)-|"
            contentViewConstraints.append(
                contentView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset)
            )
        }
        
        contentViewConstraints.append(contentsOf: [
            hFormat,
            vFormat
        ]
        .filter {
            $0.count > 0
        }
        .flatMap {
            NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: metrics, views: viewDict)
         })
        addConstraints(contentViewConstraints
//                                    .map { $0.with(priority: UILayoutPriority(999)) }
        )
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        /*
//         问题：
//         在 `private func show(to view: UIView) `方法中，视图让XYEmptyDataView的约束决定父视图的约束，以让scrollView可以垂直滚动，但是这仅仅在UIScrollView中有效，而在UITableView和UICollectionView中无效，这是因为它们的contentSize总是为0，所以我想在这里确定它们的contentSize，以让父视图scrollView可以滚动
//         */
//        if self.superview is UIScrollView {
//           let  scrollView = self.superview as! UIScrollView
//            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: self.frame.size.height)
//        }
//    }
    
    fileprivate func removeAllConstraints() {

        removeConstraints(constraints)
        contentView.removeConstraints(contentView.constraints)
    }
    
    var scrollViewContentInset: UIEdgeInsets {
        var contentInset: UIEdgeInsets!
        if self.superview is UIScrollView {
            let scrollView = self.superview as! UIScrollView
            contentInset = scrollView.contentInset
            return contentInset
        }
        return UIEdgeInsets.zero
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
        return insets != .zero
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

private extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
