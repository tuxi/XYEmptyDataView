# XYEmptyDataView
为`UIView`扩展的`emptyData`属性，用于展示空数据视图。

### 使用说明
- 空数据一般是展示在一个`UIview`上面，在`UIview`上显示或隐藏时，我们需要手动的触发它，比如：
```
private var isLoading = false {
    didSet {
        if isLoading == false {
            if dataArray.count > 0 {
                self.view.emptyData?.hide()
            }
            else {
                self.view.emptyData?.show()
            }
        }
        else {
            self.view.emptyData?.show(with: ExampleEmptyDataState.loading)
        }
    }
}
```

- 而在`UITableView`或者`UICollectionView`上面显示时，不需要手动触发，我们只需要调用系统方法`reloadData`即可，这是因为对`reloadData`方法进行了方法交换，我已经自动处理了显示和隐藏的过程，这些是在`UIScrollView+XYEmptyData.swift`中实现的。


- 空数据视图，通常会展示2种状态的视图：1.无数据、2.网络异常，其他的可通过自定义，而基于不同的页面大致可能是文案或图片展示不同，所以我们使用Swift中的枚举去区分这些状态。


### 示例
基于以上，我们将不同的状态定义为枚举的一个case，当显示空数据时，展示不同的信息即可。
定义一个空数据状态的枚举，让实现`XYEmptyDataState`协议，以规范行为
```swift
enum ExampleEmptyDataState: XYEmptyDataState {
    /// 无本地生活
    case noLocalLife
    /// 无消息
    case noMessage
    /// 无网络
    case noInternet
    /// 加载中
    case loading
    
    var title: ((UILabel) -> Void)? {
        return {
            switch self {
            case .noLocalLife,
                $0.text = "空视图测试"
            case .noMessage:
                $0.text = "还没有消息呢"
            case .noInternet:
                $0.text = nil
            case .loading:
                $0.text = nil
            }
        }
    }
    
    var detail: ((UILabel) -> Void)? {
        return {
            $0.numberOfLines = 0
            switch self {
            case .noLocalLife,
                $0.text = "暂无数据"
            case .noMessage:
                $0.text = "暂无消息"
            case .noInternet:
                $0.text = "暂无网络"
            case .loading:
                $0.text = nil
            }
        }
    }
    
    var button: ((UIButton) -> Void)? {
        return {
            $0.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
            $0.layer.cornerRadius = 5.0
            $0.layer.masksToBounds = true
            switch self {
            case .loading:
                $0.setTitle(nil, for: .normal)
            case .noInternet:
                $0.setTitle("设置", for: .normal)
            default:
                $0.setTitle("点击重试", for: .normal)
            }
        }
    }
    
    var image: ((UIImageView) -> Void)? {
        return {
            switch self {
            case .noLocalLife:
                $0.image = UIImage(named: "icon_default_empty")
            case .noMessage:
                $0.image = UIImage(named: "empty_noBinddate")
            case .noInternet:
                $0.image = UIImage(named: "empty_network")
            case .loading:
                $0.image = nil
            }
        }
    }
    
    var customView: UIView? {
        switch self {
        case .loading:
            let indicatorView = UIActivityIndicatorView(style: .gray)
            indicatorView.startAnimating()
            return indicatorView
        default:
            return nil
        }
    }
}

```

在一个`UITableView`初始化时，初始化空视图：
```swift
private func setupEmptyDataView() {
    var emptyData = XYEmptyData.with(state: ExampleEmptyDataState.noLocalLife)
    emptyData.format.contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
    emptyData.format.imageSize = CGSize(width: 180, height: 180)
    emptyData.delegate = self
    tableView.emptyData = emptyData
}
```

实现空数据的代理
```swift
extension ViewController: XYEmptyDataDelegate {
    func emptyData(_ emptyData: XYEmptyData, didTapContentView view: UIControl) {
        requestData()
    }
    func position(forState state: XYEmptyDataState, inEmptyData emptyData: XYEmptyData) -> XYEmptyData.Position {
        if self.isLoading == true {
            let height = self.tableView.tableHeaderView?.frame.maxY ?? 0
            return .top(offset: height)
        }
        return .center(offset: 0)
    }
}
```

<img src = "https://github.com/alpface/XYEmptyDataView/blob/master/XYEmptyDataView/IMG_0778.PNG?raw=true" width = "375" height = "667" alt = "Screenshot1.png"/>

