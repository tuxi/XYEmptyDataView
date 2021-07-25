//
//  ViewController.swift
//  XYEmptyDataView
//  https://github.com/tuxi/XYEmptyDataView
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
    
    private lazy var clearButton = UIBarButtonItem(title: "clear", style: .plain, target: self, action: #selector(ViewController.clearData))
    private lazy var otherButton = UIBarButtonItem(title: "切换位置", style: .plain, target: self, action: #selector(ViewController.otherButtonClick))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupView()
        setupEmptyDataView()
        
        tableView.reloadData()
    }

    private func setupEmptyDataView() {
        var emptyData = UIScrollView.EmptyData(alignment: .center(offset: 70))
        
        emptyData.xy_textLabelBlock = { label in
            label.text = "这是空数据😁视图"
        }
        
        emptyData.xy_detailTextLabelBlock = { label in
            label.text = "暂无数据"
            label.numberOfLines = 0
        }
        
        emptyData.xy_reloadButtonBlock = { button in
            button.setTitle("点击重试", for: .normal)
            button.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
            button.layer.cornerRadius = 5.0
            button.layer.masksToBounds = true
        }
        
        emptyData.xy_imageViewBlock = { imageView in
            imageView.image = UIImage.init(named: "wow")
        }
        tableView.emptyData = emptyData
        tableView.emptyDataDelegate = self
    }

    private func setupView() {
        
//        let headerView = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
//        headerView.backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1.0)
//        headerView.numberOfLines = 0
//        headerView.textAlignment = .center
//        headerView.text = "我是headerView"
//        self.tableView.tableHeaderView = headerView
        
        view.addSubview(tableView)
        let viewDict = ["tableView": tableView]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDict))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDict))
        
        navigationItem.rightBarButtonItems = [otherButton, clearButton]
    }
    
    @objc private func clearData() {
        dataArray.removeAll()
        tableView.reloadData()
    }
    
    @objc private func otherButtonClick() {
        let value = Int.random(in: 0...10) % 3
        var emptyData = tableView.emptyData
        if value == 0 {
            emptyData?.alignment = .top
        }
        else if value == 1 {
            emptyData?.alignment = .bottom
        }
        else {
            emptyData?.alignment = .center(offset: 0)
        }
        tableView.emptyData = emptyData
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
    
    func emptyDataView(_ scrollView: UIScrollView, didClickReload button: UIButton) {
        
        self.requestData()
    }
    
    func emptyDataView(_ scrollView: UIScrollView, didTapOnContentView tap: UITapGestureRecognizer) {
        self.requestData()
    }
    
    func emptyDataView(didAppear scrollView: UIScrollView) {
        clearButton.isEnabled = false
    }
    
    func emptyDataView(didDisappear scrollView: UIScrollView) {
        clearButton.isEnabled = true
    }
    
    func emptyDataView(imageViewSizeForEmptyDataView scrollView: UIScrollView) -> CGSize {
         let screenMin = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return CGSize(width: screenMin * 0.3, height: screenMin * 0.3)
    }
    
    func emptyDataView(contentEdgeInsetsForEmptyDataView scrollView: UIScrollView) -> UIEdgeInsets {
        
        if scrollView.xy_loading == true {
            return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
    }

    func emptyDataView(contentSubviewsGlobalVerticalSpaceForEmptyDataView scrollView: UIScrollView) -> CGFloat {
        return 20.0
    }
    
    func customView(forEmptyDataView scrollView: UIScrollView) -> UIView? {
        if scrollView.xy_loading == true {
            let indicatorView = UIActivityIndicatorView(style: .gray)
            indicatorView.startAnimating()
            return indicatorView
        }
        return nil
    }
    
    fileprivate func requestData() {
        self.tableView.xy_loading = true
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
}

