//
//  EmptyDataExampleTableViewController.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

enum EmptyTableExampleDataState: XYEmptyDataState {
    case noData
    case noInternet
    case error(error: EmptyExampleError)
    case loading
    
    var title: String? {
        switch self {
        case .noData:
            return "这是空数据视图"
        case .loading:
            return nil
        case .noInternet:
            return nil
        case .error:
            return "请求失败"
        }
    }
    
    var detail: String? {
        switch self {
        case .noData:
            return "暂无数据"
        case .loading:
            return nil
        case .noInternet:
            return "暂无网络"
        case let .error(error):
            return error.description
        }
    }
    
    var titleButton: String? {
        switch self {
        case .noData:
            return "刷新"
        case .loading:
            return nil
        case .noInternet:
            return "设置"
        case .error:
            return "重新请求"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .noData:
            return UIImage(named: "icon_default_empty")
        case .loading:
            return nil
        case .noInternet, .error:
            return UIImage(named: "wow")
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
    
    var position: XYEmptyData.Position {
        switch self {
        case .loading:
            return .top(offset: 100)
        default:
            return .center(offset: -30)
        }
    }
}


class EmptyDataExampleTableViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
       
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var dataArray = [[Any]]()
    private var isLoading = false {
        didSet {
            tableView.reloadData()
        }
    }
    private var error: EmptyExampleError?
    private lazy var clearButton = UIBarButtonItem(title: "clear", style: .plain, target: self, action: #selector(EmptyDataExampleTableViewController.clearData))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupView()
        setupEmptyDataView()
        
        tableView.reloadData()
        requestData()
    }

    private func setupEmptyDataView() {
        var emptyData = XYEmptyData()
        emptyData.bind.state { [weak self] in
            if self?.isLoading == true {
                return EmptyTableExampleDataState.loading
            }
            else if let error = self?.error {
                return EmptyTableExampleDataState.error(error: error)
            }
            else {
                return EmptyTableExampleDataState.noData
            }
        }
        emptyData.contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        emptyData.imageSize = CGSize(width: 180, height: 180)
        
        emptyData.delegate = self
        tableView.emptyData = emptyData
    }

    private func setupView() {
        
        let headerView = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        headerView.backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1.0)
        headerView.titleLabel?.numberOfLines = 0
        headerView.titleLabel?.textAlignment = .center
        headerView.contentHorizontalAlignment = .center
        headerView.setTitle("我是headerView\n\n点我", for: .normal)
        headerView.setTitleColor(.black, for: .normal)
        headerView.addTarget(self, action: #selector(headerClick), for: .touchUpInside)
        self.tableView.tableHeaderView = headerView
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate(
            ["|[tableView]|", "V:|[tableView]|"].flatMap {
                NSLayoutConstraint.constraints(
                    withVisualFormat: $0,
                    options: [],
                    metrics: nil,
                    views: ["tableView": tableView]
                )
            }
        )
        
        navigationItem.rightBarButtonItems = [clearButton]
        
//        tableView.contentInsetAdjustmentBehavior = .never
//        tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
    }
    
    @objc private func clearData() {
        self.tableView.emptyData?.state = EmptyTableExampleDataState.noData
        dataArray.removeAll()
        tableView.reloadData()
    }

    @objc private func headerClick() {
//        let alert = UIAlertController(title: "谢谢🍾️🍾️🍺", message: nil, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
        
        self.navigationController?.pushViewController(ExampleViewController(), animated: true) 
    }
}

extension EmptyDataExampleTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray[section].count
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
                                                                   options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                       metrics: nil,
                                                                       views: viewDict))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(==0.8)]|",
                                                                   options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                       metrics: nil,
                                                                       views: viewDict))
        }
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "第" + NSNumber.init(value: section).stringValue + "组"
    }
    
    
}

extension EmptyDataExampleTableViewController: XYEmptyDataDelegate {
    
    func emptyData(_ emptyData: XYEmptyData, didTapButton button: UIButton) {
        requestData()
    }
   
    fileprivate func requestData() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3.0) {
            self.dataArray.removeAll()
//            for section in 0...3 {
//                var  array = Array<Any>()
//                var count = 0
//                if section % 2 == 0 {
//                    count = 3
//                }
//                else {
//                    count = 6
//                }
//                for row in 0...count {
//                    array.append(row)
//                }
//                self.dataArray.append(array)
//
//            }
            self.isLoading = false
            self.error = .serverNotConnect
            self.tableView.reloadData()
        }
    }
}

extension EmptyDataExampleTableViewController: XYEmptyDataViewAppearable {
    func emptyData(_ emptyData: XYEmptyData, didChangedApperStatus status: XYEmptyDataAppearStatus) {
        switch status {
        case .didAppear:
            clearButton.isEnabled = false
        case .didDisappear:
            clearButton.isEnabled = true
        default:
            break
        }
    }
}

enum EmptyExampleError: Error, CustomStringConvertible {
    case serverNotConnect
    
    var description: String {
        switch self {
        case .serverNotConnect:
            return "服务器无法连接"
        }
    }
}
