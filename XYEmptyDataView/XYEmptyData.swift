//
//  XYEmptyData.swift
//  XYEmptyDataView
//  https://github.com/tuxi/XYEmptyDataView
//  Created by xiaoyuan on 2018/1/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

public protocol XYEmptyDataViewAppearable {
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
    
    
    /// 是否应该淡入淡出，default is YES
    /// - Returns: Bool
    @objc
    optional func emptyDataView(shouldFadeInOnDisplay scrollView: UIScrollView) -> Bool
    
    
    /// 是否应显示emptyDataView, 默认YES
    /// - Returns: 如果当前无数据则应显示emptyDataView
    @objc
    optional func emptyDataView(shouldDisplay scrollView: UIScrollView) -> Bool
    
    
    /// 当前所在页面的数据源itemCount>0时，是否应该实现emptyDataView，default return NO
    /// - Returns: 如果需要强制显示emptyDataView，return YES即可
    @objc
    optional func emptyDataView(shouldForcedDisplay scrollView: UIScrollView) -> Bool
    
    @objc
    optional func emptyDataView(_ scrollView: UIScrollView, didTapReloadButton button: UIButton)
    
}

/// 存放一些空数据的结果
public struct EmptyData {
    public typealias Delegate = XYEmptyDataDelegate & XYEmptyDataViewAppearable
    public enum Position {
        case center(offset: CGFloat = 0)
        case top
        case bottom
    }
    public class ViewBinder {
        fileprivate var xy_textLabelBlock: ((UILabel) -> Void)?
        fileprivate var xy_detailTextLabelBlock: ((UILabel) -> Void)?
        fileprivate var xy_imageViewBlock: ((UIImageView) -> Void)?
        fileprivate var xy_reloadButtonBlock: ((UIButton) -> Void)?
        
        fileprivate var customView: (() -> UIView?)?
        
        fileprivate var xy_textEdgeInsets: UIEdgeInsets = .zero
        fileprivate var xy_imageEdgeInsets: UIEdgeInsets = .zero
        fileprivate var xy_detailEdgeInsets: UIEdgeInsets = .zero
        fileprivate var xy_buttonEdgeInsets: UIEdgeInsets = .zero
        
        fileprivate var position: (() -> Position?)?
        
        fileprivate init() {}
    }
    
    /// 对齐方法，分为：上、下、中间
    public var position: Position
    public var contentEdgeInsets: UIEdgeInsets = .zero
    
    public var backgroundColor: UIColor?
    /// 空数据`contentView`的背景颜色
    public var contentBackgroundColor: UIColor?
    /// 各子控件之间垂直的间距，默认为11
    public var itemPadding: CGFloat = 11
    /// `imageView`的宽高，默认为`nil`，让其自适应
    public var imageSize: CGSize?
    public weak var delegate: Delegate?
    public let view = ViewBinder()
}

extension UIScrollView: UIGestureRecognizerDelegate {
    
    /// 用于关联对象的keys
    private struct XYEmptyDataKeys {
        static var emptyDataView = "com.alpface.XYEmptyData.emptyDataView"
        static var registerEmptyDataView = "com.alpface.XYEmptyData.registerEemptyDataView"
        
        static var config = "com.alpface.XYEmptyData.config"
    }
    
    open var emptyData: EmptyData? {
        get {
            return objc_getAssociatedObject(self, &XYEmptyDataKeys.config) as? EmptyData
        }
        set {
            objc_setAssociatedObject(self, &XYEmptyDataKeys.config, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            registerEmptyDataView()
            xy_reloadEmptyDataView()
        }
    }
    
    private var emptyDataView: XYEmptyDataView? {
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
    private func setupEmptyDataView() {
        var view = self.emptyDataView
        if view == nil {
            view = XYEmptyDataView.show(withView: self, animated: xy_emptyDataViewShouldFadeInOnDisplay())
//            view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view?.isHidden = true
            
            self.emptyDataView = view
        }
    }
    
    
    private func registerEmptyDataView() {
        
        /// 保证这里只初始化一次
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
            emptyDataView.position = emptyData.view.position?() ?? emptyData.position
            
            if let closure = emptyData.view.customView, let view = closure() {
                emptyDataView.customView = view
            } else {
                // customView为nil时，则通过block回到获取子控件 设置
                if let block = emptyData.view.xy_textLabelBlock  {
                    block(emptyDataView.titleLabel)
                }
                if let block = emptyData.view.xy_detailTextLabelBlock {
                    block(emptyDataView.detailLabel)
                }
                
                if let block = emptyData.view.xy_imageViewBlock {
                    block(emptyDataView.imageView)
                }
                if let block = emptyData.view.xy_reloadButtonBlock {
                    block(emptyDataView.reloadButton)
                }
                
                // 设置子控件之间的边距
                emptyDataView.titleEdgeInsets = emptyData.view.xy_textEdgeInsets
                emptyDataView.detailEdgeInsets = emptyData.view.xy_detailEdgeInsets
                emptyDataView.imageEdgeInsets = emptyData.view.xy_imageEdgeInsets
                emptyDataView.buttonEdgeInsets = emptyData.view.xy_buttonEdgeInsets
                // 设置emptyDataView子控件垂直间的间距
                emptyDataView.globalVerticalSpace = emptyData.itemPadding
                
            }
            
            emptyDataView.contentEdgeInsets = emptyData.contentEdgeInsets
            emptyDataView.backgroundColor = emptyData.backgroundColor
            emptyDataView.contentView.backgroundColor = emptyData.contentBackgroundColor
            emptyDataView.isHidden = false
            emptyDataView.clipsToBounds = true
            emptyDataView.imageViewSize = emptyData.imageSize ?? .zero
            
            emptyDataView.setNeedsUpdateConstraints()
            
            // 此方法会先检查动画当前是否启用，然后禁止动画，执行block块语句
            UIView.performWithoutAnimation {
                emptyDataView.layoutIfNeeded()
            }
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

        // 通知代理完全消失
        self.xy_emptyDataViewDidDisappear()
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
        
        return itemCount;
    }
    
    /// 是否需要淡入淡出
    private func xy_emptyDataViewShouldFadeInOnDisplay() -> Bool {
        guard let del = self.emptyData?.delegate else {
            return true
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(shouldFadeInOnDisplay:))) {
            return del.emptyDataView!(shouldFadeInOnDisplay: self)
        }
        
        return true
    }
    
    /// 是否应该显示
    private func xy_emptyDataViewShouldDisplay() -> Bool {
        guard let del = self.emptyData?.delegate else {
            return true
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(shouldDisplay:))) {
            return del.emptyDataView!(shouldDisplay: self)
        }
        return true
    }
    
    /// 是否应该强制显示,默认不需要的
    private func xy_emptyDataViewShouldBeForcedToDisplay() -> Bool {
        guard let del = self.emptyData?.delegate else {
            return false
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(shouldForcedDisplay:))) {
            return del.emptyDataView!(shouldForcedDisplay: self)
        }
        return false
    }
    
    /// 点击空数据视图的 reload的回调
    @objc fileprivate func xy_clickReloadBtn(btn: UIButton) {
        guard let del = self.emptyData?.delegate else {
            return
        }
        if del.responds(to: #selector(XYEmptyDataDelegate.emptyDataView(_:didTapReloadButton:))) {
            del.emptyDataView!(self, didTapReloadButton: btn)
        }
    }

}




private let EmptyDataViewHorizontalSpaceRatioValue: CGFloat = 16.0

private class _WeakObjectContainer : NSObject {
    
    
    weak open var weakObject: AnyObject?
    
    
    public init(weakObject: AnyObject) {
        self.weakObject = weakObject
    }
}


extension UIView {
    
   private struct XYEmptyDataKeys {
        static var emptyDataViewContentEdgeInsets = "com.alpface.XYEmptyData.emptyDataViewContentEdgeInsets"
    }
    fileprivate var emptyDataViewContentEdgeInsets: UIEdgeInsets {
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

private class XYEmptyDataView : UIView {
    
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
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
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
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    /// 图片
    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
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
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
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
    
    var position: EmptyData.Position = .center(offset: 0)
    
    /** imageView的size, 有的时候图片本身太大，导致imageView的尺寸并不是我们想要的，可以通过此方法设置, 当为CGSizeZero时不设置,默认为CGSizeZero */
    var imageViewSize: CGSize = .zero
    
    /** tap手势回调block */
    var tapGestureRecognizerBlock: ((UITapGestureRecognizer) -> Swift.Void)?
    
    private var superConstraints = [NSLayoutConstraint]()
    private var contentViewConstraints = [NSLayoutConstraint]()
    private var subConstraints = [NSLayoutConstraint]()
    
    convenience init(_ view: UIView) {
        self.init(frame: view.bounds)
        show(withView: view)
    }
    
    private func show(withView view: UIView) {
        clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        if view.subviews.count > 1 {
            view.insertSubview(self, at: 0)
        }
        else {
            view.addSubview(self)
        }
       
        let superview: UIView = view
        superview.removeConstraints(superConstraints)
        superConstraints.removeAll()
        
        let left = scrollViewContentInset.left
        let top = scrollViewContentInset.top
        let right = scrollViewContentInset.right
        let bottom = scrollViewContentInset.bottom
        let metrics: [String: Any] = ["left": left, "right": right, "top": top, "bottom": bottom]
        
        superConstraints.append(contentsOf: [
            "H:|-(left)-[self]-(right)-|",
            "V:|-(top)-[self]-(bottom)-|"
        ]
        .flatMap {
            NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: metrics, views: ["self": self])
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
        
        contentView.removeConstraints(subConstraints)
        
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
        updateMyConstraints()
        updateContentViewConstraints()
        updateSubConstraints()
        super.updateConstraints()
    }
    
    /// 更新自身的约束到父视图
    private func updateMyConstraints() {
        guard superConstraints.count > 0 else {
            return
        }
        
        let inset = scrollViewContentInset
        /// 修复`contentInst`引发的布局偏移问题，上下左右间距需固定为0
        superConstraints.forEach {
            switch $0.firstAttribute {
            case .top:
//                $0.constant = inset.top
                $0.constant = 0
            case .bottom:
//                $0.constant = inset.bottom
                $0.constant = 0
            case .left, .leading:
//                $0.constant = inset.left
                $0.constant = 0
            case .right, .trailing:
//                $0.constant = inset.right
                $0.constant = 0
            case .width:
                $0.constant = -(inset.left + inset.right)
            case .height:
                $0.constant = -(inset.top + inset.bottom)
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

        switch position {
        case .top:
            vFormat = "V:|-(top)-[contentView]-(<=bottom@600)-|"
        case .bottom:
            vFormat = "V:|-(>=top@600)-[contentView]-(bottom)-|"
        case .center(let offset):
            vFormat = "V:|-(>=top@800)-[contentView]-(<=bottom@800)-|"
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
        addConstraints(contentViewConstraints)
    }
    
    private func updateSubConstraints() {
        contentView.removeConstraints(subConstraints)
        subConstraints.removeAll()
        
        // 若有customView 则 让其与contentView的约束相同
        if let customView = customView {
            self.contentView.addSubview(customView)
            
            subConstraints.append(contentsOf: [
                "H:|[customView]|", "V:|[customView]|"
            ]
            .flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: ["customView": customView])
            })
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
                    subConstraints.append(contentsOf: (NSLayoutConstraint.constraints(withVisualFormat: "H:|-(imageLeftSpace)-[imageView]-(imageRightSpace)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict)))
                    
                }
                else {
                    subConstraints.append(contentsOf: [
                        NSLayoutConstraint.init(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                        imageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 10),
                        imageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10)
                    ])
                }
                if self.imageViewSize.width > 0.0 && self.imageViewSize.height > 0.0 {
                    subConstraints.append(contentsOf: [
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
                
                subConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-(titleLeftSpace)-[titleLabel(>=0)]-(titleRightSpace)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
                
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
                subConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(detailLeftSpace)-[detailLabel(>=0)]-(detailRightSpace)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
          
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
                
                subConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(buttonLeftSpace)-[reloadButton(>=0)]-(buttonRightSpace)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
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
                
                verticalFormat += "-(\(topSpace))-[\(viewName)]"
                
                if (viewName == subviewKeyArray.last) {
                    // 最后一个控件把距离父控件底部的约束值也加上
                    verticalFormat += "-(\(view.emptyDataViewContentEdgeInsets.bottom))-"
                }
                
                previousView = view;
            }
            
            previousView = nil;
            // 向contentView分配垂直约束
            if (verticalFormat.count > 0) {
                subConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|\(verticalFormat)|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
            }
        }
        
        contentView.addConstraints(subConstraints)
    }
    
    /// 获取安全边距边距
    var scrollViewContentInset: UIEdgeInsets {
        var inset: UIEdgeInsets = .zero
        if self.superview is UIScrollView {
            let scrollView = self.superview as! UIScrollView
            let safeAreaInsets = scrollView.safeAreaInsets
            let adjustedContentInset = scrollView.adjustedContentInset
            let contentInset = scrollView.contentInset
            
            inset.top = max(max(safeAreaInsets.top, adjustedContentInset.top), contentInset.top)
            inset.bottom = max(max(safeAreaInsets.bottom, adjustedContentInset.bottom), contentInset.bottom)
            inset.left = max(max(safeAreaInsets.left, adjustedContentInset.left), contentInset.left)
            inset.right = max(max(safeAreaInsets.right, adjustedContentInset.right), contentInset.right)
//            if scrollView.contentInsetAdjustmentBehavior == .always {
//                /// 解决`contentInsetAdjustmentBehavior == .always`的偏移问题
//                inset.top -= adjustedContentInset.top
//                inset.bottom -= adjustedContentInset.bottom
//                inset.left -= adjustedContentInset.left
//                inset.right -= adjustedContentInset.right
//            }
        }
        return inset
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

extension UIScrollView {
    /// 即将显示空数据时调用
    private func xy_emptyDataViewWillAppear() {
        emptyData?.delegate?.emptyDataView(willAppear: self)
    }
   
    /// 已经显示空数据时调用
    private func xy_emptyDataViewDidAppear() {
        // 这里以UITableView为例: 当调用原reloadData后，tableView的contentSize会被重置为所有cell的高度，而显示空数据时，tableView并没有数据，所以导致contentSize被重置为zero，导致空视图超出tableView的高度时依旧无法滚动
//        DispatchQueue.main.async {
//            let contentSize = self.contentSize
//            self.contentSize = CGSize(width: contentSize.width == 0 ? self.emptyDataView?.frame.size.width ?? 0 : 0, height: (self.emptyDataView?.frame.size.height ?? 0))
//        }
        emptyData?.delegate?.emptyDataView(didAppear: self)
    }

    /// 空数据即将消失时调用
    private func xy_emptyDataViewWillDisappear() {
        emptyData?.delegate?.emptyDataView(willDisappear: self)
    }
   
    /// 空数据已经消失时调用
    private func xy_emptyDataViewDidDisappear() {
        emptyData?.delegate?.emptyDataView(didDisappear: self)
    }
}

extension XYEmptyDataViewAppearable {
    func emptyDataView(willAppear scrollView: UIScrollView) {}
    func emptyDataView(didAppear scrollView: UIScrollView) {}
    func emptyDataView(willDisappear scrollView: UIScrollView) {}
    func emptyDataView(didDisappear scrollView: UIScrollView) {}
}

extension EmptyData.ViewBinder {
    @discardableResult
    public func title(_ closure: @escaping (UILabel) -> Void) -> Self {
        self.xy_textLabelBlock = closure
        return self
    }
    @discardableResult
    public func detail(_ closure: @escaping (UILabel) -> Void) -> Self {
        self.xy_detailTextLabelBlock = closure
        return self
    }
    
    @discardableResult
    public func reload(_ closure: @escaping (UIButton) -> Void) -> Self {
        self.xy_reloadButtonBlock = closure
        return self
    }
    @discardableResult
    public func image(_ closure: @escaping (UIImageView) -> Void) -> Self {
        self.xy_imageViewBlock = closure
        return self
    }
    
    @discardableResult
    public func custom(_ closure: @escaping () -> UIView?) -> Self {
        self.customView = closure
        return self
    }
    @discardableResult
    public func position(_ closure: @escaping () -> EmptyData.Position?) -> Self {
        self.position = closure
        return self
    }
}

