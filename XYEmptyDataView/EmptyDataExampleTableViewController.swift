//
//  EmptyDataExampleTableViewController.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

class EmptyDataExampleTableViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
       
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
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
        var emptyData = XYEmptyData.with(state: ExampleEmptyDataState.noBinddate)
        emptyData.format.contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        emptyData.format.imageSize = CGSize(width: 180, height: 180)
        
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
    }
    
    @objc private func clearData() {
        dataArray.removeAll()
        tableView.reloadData()
    }

    @objc private func headerClick() {
        self.navigationController?.pushViewController(ExampleViewController(), animated: true) 
    }
    
    fileprivate func requestData() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3.0) {
            self.dataArray.removeAll()
            self.isLoading = false
            self.error = .serverNotConnect
            self.tableView.reloadData()
        }
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
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "第" + NSNumber.init(value: section).stringValue + "组"
    }
}

extension EmptyDataExampleTableViewController: XYEmptyDataDelegate {
    func emptyData(_ emptyData: XYEmptyData, didTapContentView view: UIControl) {
        requestData()
    }
    
    func emptyData(_ emptyData: XYEmptyData, didTapButton button: UIButton) {
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

extension EmptyDataExampleTableViewController: XYEmptyDataStateDelegate {
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

extension EmptyDataExampleTableViewController: XYEmptyDataAppearable {
    func emptyData(_ emptyData: XYEmptyData, didChangedAppearStatus status: XYEmptyData.AppearStatus) {
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
