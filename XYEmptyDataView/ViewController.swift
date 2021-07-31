//
//  ViewController.swift
//  XYEmptyDataView
//  
//  Created by xiaoyuan on 2018/1/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
    
    private lazy var clearButton = UIBarButtonItem(title: "clear", style: .plain, target: self, action: #selector(ViewController.clearData))
    
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
        
        //        tableView.contentInsetAdjustmentBehavior = .never
        //        tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
    }
    
    @objc private func clearData() {
        dataArray.removeAll()
        tableView.reloadData()
    }
    
    @objc private func headerClick() {
        
        let vc = EmptyDataExampleTableViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func requestData() {
        isLoading = true
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
            self.isLoading = false
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
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

extension ViewController: XYEmptyDataDelegate {
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
    
    func state(forEmptyData emptyData: XYEmptyData) -> XYEmptyDataState {
        if self.isLoading == true {
            return ExampleEmptyDataState.loading
        }
        return ExampleEmptyDataState.noLocalLife
    }
}

extension ViewController: XYEmptyDataAppearable {
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
