//
//  XYEmptyDataView.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

internal class XYEmptyDataView : UIView {
    
    struct ViewModel {
        var image: UIImage?
        var title: String?
        var detail: String?
        var titleButton: String?
        var customView: UIView?
    }
    
    // MARK: - Views
    lazy var contentView: UIControl = {
        let contentView = UIControl()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        contentView.alpha = 0.0
        contentView.addTarget(self, action: #selector(clickContentButton(_:)), for: .touchUpInside)
        return contentView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
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
    
    lazy var detailLabel: UILabel = {
        let label = UILabel()
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
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        return imageView
    }()
    
    lazy var reloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(XYEmptyDataView.clickButton(_:)), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        return button
    }()
    
    var customView: UIView? {
        willSet {
            customView?.removeFromSuperview()
        }
        didSet {
            if let customView = self.customView {
                customView.translatesAutoresizingMaskIntoConstraints = false
                self.contentView.addSubview(customView)
            }
        }
    }
    
    // MARK: - Properties
    
    var contentEdgeInsets: UIEdgeInsets = .zero
    
    /// 所有子控件之间垂直间距
    var globalVerticalSpace: CGFloat = 10.0
    
    var position: XYEmptyData.Position = .center(offset: 0)
    
    /// `imageView.size`, 有的时候图片本身太大，导致imageView的尺寸并不是我们想要的，可以通过此方法设置, 当为CGSizeZero时不设置,默认为CGSizeZero
    var imageViewSize: CGSize = .zero
    
    /// 点击刷新按钮的回调
    var tapButonBlock: ((UIButton) -> Void)?
    /// 点击contentView的回调
    var tapContentViewBlock: ((UIControl) -> Void)?
    
    private var superConstraints = [NSLayoutConstraint]()
    private var contentViewConstraints = [NSLayoutConstraint]()
    private var subConstraints = [NSLayoutConstraint]()
    
    deinit {
        print(String(describing: self) + #function)
    }
    
    func show(on view: UIView, animated: Bool) {
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
        
        if superview is UIScrollView {
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
        }
        else {
            if #available(iOS 11.0, *) {
                superConstraints.append(contentsOf: [
                    self.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: left),
                    superview.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: right),
                    self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: top),
                    superview.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom)
                ])
            } else {
                superConstraints.append(contentsOf: [
                    self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: left),
                    superview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: right),
                    self.topAnchor.constraint(equalTo: superview.topAnchor, constant: top),
                    superview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom)
                ])
            }
        }
        superview.addConstraints(superConstraints)
        
        showAnimated(animated)
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
    
    private func showAnimated(_ animated: Bool) {
        
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.contentView.alpha = 1.0
        }
    }
    
    /// 点击刷新按钮时处理事件
    @objc private func clickButton(_ btn: UIButton) {
        tapButonBlock?(btn)
    }
    
    /// 点击整个content时处理事件
    @objc private func clickContentButton(_ btn: UIControl) {
        tapContentViewBlock?(btn)
    }
    
    // MARK: - Constraints
    override func updateConstraints() {
        updateMyConstraints()
        updateContentViewConstraints()
        updateSubConstraints()
        super.updateConstraints()
    }
    
    /// 获取安全边距边距
    var scrollViewContentInset: UIEdgeInsets {
        var inset: UIEdgeInsets = .zero
        if self.superview is UIScrollView {
            let scrollView = self.superview as! UIScrollView
            var safeAreaInsets = UIEdgeInsets.zero
            var adjustedContentInset = UIEdgeInsets.zero
            if #available(iOS 11.0, *) {
                safeAreaInsets = scrollView.safeAreaInsets
                adjustedContentInset = scrollView.adjustedContentInset
            }
            let contentInset = scrollView.contentInset
            
            inset.top = max(max(safeAreaInsets.top, adjustedContentInset.top), contentInset.top)
            inset.bottom = max(max(safeAreaInsets.bottom, adjustedContentInset.bottom), contentInset.bottom)
            inset.left = max(max(safeAreaInsets.left, adjustedContentInset.left), contentInset.left)
            inset.right = max(max(safeAreaInsets.right, adjustedContentInset.right), contentInset.right)
        }
        return inset
    }
    
    // MARK: - Touchs
    /// 重载`hitTest`方法，以防止空数据视图影响`scrollView`的时间传递
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
            let pointInContentView = convert(point, to: contentView)
            return touchView.hitTest(pointInContentView, with: event)
        }
        if let customView = customView {
            if touchView.isEqual(customView) {
                let pointInCustomView = convert(point, to: customView)
                return touchView.hitTest(pointInCustomView, with: event)
            }
        }
        return nil
    }
    
}

private extension XYEmptyDataView {
    // MARK: - Others
    var canShowImage: Bool {
        return imageView.image != nil //&& imageView.superview != nil
    }
    
    var canShowTitle: Bool {
        return titleLabel.text != nil //&& titleLabel.superview != nil
    }
    
    var canShowDetail: Bool {
        return detailLabel.text != nil // && detailLabel.superview != nil
    }
    
    var canShowReloadButton: Bool {
        if (reloadButton.title(for: .normal) != nil) ||
            (reloadButton.image(for: .normal) != nil) ||
            (reloadButton.attributedTitle(for: .normal) != nil) {
            return true//reloadButton.superview != nil
        }
        return false
    }
}

/// 更新视图
extension XYEmptyDataView {
    func update(_ emptyData: XYEmptyData, for state: XYEmptyDataState) {
        let emptyDataView = self
        // 重置视图及其约束
        emptyDataView.resetSubviews()
    
        if let customView = state.customView {
            emptyDataView.customView = customView
        } else {
            // customView为nil时，则通过block配置子控件
            state.title?(emptyDataView.titleLabel)
            state.detail?(emptyDataView.detailLabel)
            state.image?(emptyDataView.imageView)
            state.button?(emptyDataView.reloadButton)
            
            // 设置emptyDataView子控件垂直间的间距
            emptyDataView.globalVerticalSpace = emptyData.format.itemPadding
        }
        emptyDataView.position = emptyData.delegate?.position(forState: state, inEmptyData: emptyData) ?? .center(offset: 0)
        emptyDataView.contentEdgeInsets = emptyData.format.contentEdgeInsets
        emptyDataView.backgroundColor = emptyData.format.backgroundColor
        emptyDataView.contentView.backgroundColor = emptyData.format.contentBackgroundColor
        emptyDataView.imageViewSize = emptyData.format.imageSize ?? .zero
        
        emptyDataView.isHidden = false
        emptyDataView.clipsToBounds = true
        
        emptyDataView.setNeedsUpdateConstraints()
        
        // 此方法会先检查动画当前是否启用，然后禁止动画，执行block块语句
        UIView.performWithoutAnimation {
            emptyDataView.layoutIfNeeded()
        }
    }
}

/// Constraints约束相关
extension XYEmptyDataView {
    /// 更新自身的约束到父视图
    func updateMyConstraints() {
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
    
    func updateContentViewConstraints() {
        removeConstraints(contentViewConstraints)
        contentViewConstraints.removeAll()
        
        let viewDict = ["contentView": contentView]
        var metrics: [String: Any] = [:]
        let hFormat = "H:|-(left)-[contentView]-(right)-|"
        var vFormat = "V:|-(top)-[self]-(bottom)-|"
        var top = contentEdgeInsets.top
        var bottom = contentEdgeInsets.bottom
        
        switch position {
        case .top(let offset):
            top += offset
            vFormat = "V:|-(top)-[contentView]-(<=bottom@600)-|"
        case .bottom(let offset):
            bottom += offset
            vFormat = "V:|-(>=top@600)-[contentView]-(bottom)-|"
        case .center(let offset):
            vFormat = "V:|-(>=top@800)-[contentView]-(<=bottom@800)-|"
            contentViewConstraints.append(
                contentView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset)
            )
        }
        metrics = ["left": contentEdgeInsets.left, "right": contentEdgeInsets.right, "top": top, "bottom": bottom]
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
    
    func updateSubConstraints() {
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
            let ratioValue: CGFloat = 16.0
            // contentView的子控件横向间距  四舍五入
            let horizontalSpace = CGFloat(roundf(Float(UIScreen.main.bounds.width / ratioValue)))
            // contentView的子控件之间的垂直间距，默认为10.0
            let globalverticalSpace = self.globalVerticalSpace
            
            var subviewKeyArray = [String]()
            var subviewDict = [String: UIView]()
            var metrics = ["horizontalSpace": horizontalSpace] as [String : Any]
            
            // 设置imageView水平约束
            if canShowImage {
                self.contentView.addSubview(self.imageView)
                subviewKeyArray.append("imageView")
                subviewDict[subviewKeyArray.last!] = imageView
                
                let imageLeftSpace = horizontalSpace
                let imageRightSpace = horizontalSpace
                subConstraints.append(contentsOf: [
                    NSLayoutConstraint.init(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                    imageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: imageLeftSpace),
                    imageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -imageRightSpace)
                ])
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
            if canShowTitle {
                self.contentView.addSubview(self.titleLabel)
                let titleLeftSpace = horizontalSpace
                let titleRightSpace = horizontalSpace
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
            if canShowDetail {
                self.contentView.addSubview(self.detailLabel)
                
                let detailLeftSpace = horizontalSpace
                let detailRightSpace = horizontalSpace
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
            if canShowReloadButton {
                self.contentView.addSubview(self.reloadButton)
                let buttonLeftSpace = horizontalSpace
                let buttonRightSpace = horizontalSpace
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
            let space = globalverticalSpace
            for viewName in subviewKeyArray {
                guard subviewDict[viewName] != nil else {
                    continue
                }
                // 拼接间距值
                verticalFormat += "-(\(space))-[\(viewName)]"
                
                if viewName == subviewKeyArray.last {
                    // 最后一个控件把距离父控件底部的约束值也加上
                    verticalFormat += "-(\(space))-"
                }
            }
            // 向contentView分配垂直约束
            if verticalFormat.count > 0 {
                subConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|\(verticalFormat)|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: subviewDict))
            }
        }
        
        contentView.addConstraints(subConstraints)
    }
    
}
