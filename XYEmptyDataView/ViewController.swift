//
//  ViewController.swift
//  XYEmptyDataView
//
//  Created by swae on 2018/1/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

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
        
        for i in 0...30 {
            dataArray.append(i)
        }
        self.tableView.reloadData()
    }
    
    func emptyDataView(imageViewSizeforEmptyDataView scrollView: UIScrollView) -> CGSize {
        
        return CGSize(width: 280, height: 280)
    }
    
    func emptyDataView(contentOffsetforEmptyDataView scrollView: UIScrollView) -> CGPoint {
        return CGPoint(x: 0, y: -20)
    }

    func emptyDataView(contentSubviewsGlobalVerticalSpaceForEmptyDataView scrollView: UIScrollView) -> CGFloat {
        return 20.0
    }
}

