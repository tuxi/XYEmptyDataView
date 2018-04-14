# XYEmptyDataView
iOS项目中用于展示空数据的视图，UIScrollView空数据视图分类，Swift4.

#### 使用简单
XYEmptyDataView中使用了Method Swizzle，对UITableView和UICollectionView的reloadData方法进行加工，最终才有了如此简单使用的空数据视图，项目中有示例

#### AutoLayout
使用AutoLayout布局


#### 使用说明
首先XYEmptyDataView拖入项目中
```
import UIKit

class ViewController: UIViewController {

    fileprivate lazy var tableView: UITableView = {
    
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    fileprivate lazy var dataArray = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupView()
        setupEmptyDataView()
        
        tableView.reloadData()
    }

    private func setupEmptyDataView() {
        tableView.xy_textLabelBlock = { label in
            label.text = "空数据😁简单展示"
        }
        
        tableView.xy_detailTextLabelBlock = { label in
            label.text = "这是一个测试\n😝😝😝"
        }
        
        tableView.xy_reloadButtonBlock = { button in
            button.setTitle("刷新吧", for: .normal)
            button.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
            button.layer.cornerRadius = 5.0
            button.layer.masksToBounds = true
        }
        
        tableView.xy_imageViewBlock = { imageView in
            imageView.image = UIImage.init(named: "wow")
        }
        
        tableView.emptyDataDelegate = self
    }

    private func setupView() {
        view.addSubview(tableView)
        let viewDict = ["tableView": tableView]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "clear", style: .plain, target: self, action: #selector(ViewController.clearData))
    }
    
    @objc private func clearData() {
        dataArray.removeAll()
        tableView.reloadData()
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let line = cell.viewWithTag(111)
        if line == nil {
            let line = UIView(frame: .zero)
            line.translatesAutoresizingMaskIntoConstraints = false
            line.accessibilityIdentifier = "line_"
            line.tag = 111
            cell.addSubview(line)
            line.backgroundColor = UIColor.lightGray
            let viewDict = ["line": line]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|[line]|",
                                                                       options: NSLayoutFormatOptions(rawValue: 0),
                                                                       metrics: nil,
                                                                       views: viewDict))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(==0.8)]|",
                                                                       options: NSLayoutFormatOptions(rawValue: 0),
                                                                       metrics: nil,
                                                                       views: viewDict))
        }
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
}

extension ViewController: XYEmptyDataDelegate {
    
    func emptyDataView(_ scrollView: UIScrollView, didClickReload button: UIButton) {
        scrollView.xy_loading = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3.0) {
            self.dataArray.removeAll()
            for section in 0...3 {
                var  array = Array<Any>()
                var count = 0
                if section % 2 == 0 {
                    count = 3
                }
                else {
                    count = 6
                }
                for row in 0...count {
                    array.append(row)
                }
                self.dataArray.append(array)
                
            }
            self.tableView.xy_loading = false
            self.tableView.reloadData()
        }
        
    }
    
    func emptyDataView(didAppear scrollView: UIScrollView) {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func emptyDataView(didDisappear scrollView: UIScrollView) {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func emptyDataView(imageViewSizeforEmptyDataView scrollView: UIScrollView) -> CGSize {
         let screenMin = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return CGSize(width: screenMin * 0.3, height: screenMin * 0.3)
    }
    
    func emptyDataView(contentOffsetforEmptyDataView scrollView: UIScrollView) -> CGPoint {
        if scrollView.xy_loading == true {
            return CGPoint(x: 0, y: -scrollView.frame.size.height*0.5 + 20.0)
        }
        return CGPoint(x: 0, y: -20)
    }

    func emptyDataView(contentSubviewsGlobalVerticalSpaceForEmptyDataView scrollView: UIScrollView) -> CGFloat {
        return 20.0
    }
    
    func customView(forEmptyDataView scrollView: UIScrollView) -> UIView? {
        if scrollView.xy_loading == true {
            let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicatorView.startAnimating()
            return indicatorView
        }
        return nil
    }
}

```

<img src = "https://github.com/alpface/XYEmptyDataView/blob/master/XYEmptyDataView/IMG_0778.PNG?raw=true" width = "375" height = "667" alt = "Screenshot1.png"/>

