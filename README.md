# XYEmptyDataView
为`UIView`扩展的`emptyData`属性，用于展示空视图。
空数据视图，通常是在缺省状态下展示：不同页面的无数据状态、网络异常。这些UI相对简单，但是频繁的处理不同状态下的空数据视图似乎有些多余，通过`XYEmptyData`很好的解决这个问题。

你可以实现`XYEmptyDataState`协议，去自定义不同状态下的空数据视图，这里我很中意`swift`中的枚举，因为它可以很好的区分这些状态。

### 使用说明

#### CocoaPods 安装

```ruby
pod 'XYEmptyDataView'
```

#### 示例

- 初始化空视图，初始化时设置一个初始`state`，以便需要时显示，
由`UIview`的实例引用了`emptyData`，对空视图的操作，都在`emptyData`中。
```swift
func setupEmptyDataView() {
    var emptyData = XYEmptyData.with(state: ExampleEmptyDataState.noMessage)
    emptyData.format.contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
    emptyData.format.imageSize = CGSize(width: 180, height: 180)
    emptyData.delegate = self
    view.emptyData = emptyData
    emptyData.show()
}

```

- 在`UIview`上展示空视图，除了初始化以外，在需要时，需主动调用`show()`或者`hide()`去显示或隐藏空视图

```swift
class ExampleViewController: UIViewController {
    private lazy var dataArray = [[Any]]()
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
}
```
- 在`UITableView`或者`UICollectionView`上展示空视图，无需主动显示或隐藏，这是内部已交换`reloadData`方法，在执行`reloadData`方法时根据`state`刷新空视图，你可以使用初始化时候的状态，也可以根据需求绑定一个状态，比如：无数据、网络异常等，在显示时根据状态显示UI。绑定状态需要实现`XYEmptyDataDelegateState`协议

```swift
extension EmptyDataExampleTableViewController: XYEmptyDataDelegateState {
    func state(forEmptyData emptyData: XYEmptyData) -> XYEmptyDataState? {
        if self.isLoading == true {
            return ExampleEmptyDataState.loading
        }
        else if let error = self.error {
            return ExampleEmptyDataState.error(error)
        }
        else {
            return ExampleEmptyDataState.noBinddate
        }
    }
}
```

### 示例
`ExampleEmptyDataState`是根据业务定义的空视图状态，它实现了`XYEmptyDataState`协议，由于它是枚举，所以很好的反应不同状态下的样式。
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

<img src = "https://github.com/alpface/XYEmptyDataView/blob/master/XYEmptyDataViewExample/IMG_0778.PNG?raw=true" width = "390" height = "844" alt = "Screenshot1.png"/>
