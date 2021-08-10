//
//  ViewController.swift
//  XYEmptyDataView
//  
//  Created by xiaoyuan on 2018/1/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import XYEmptyDataView

class ViewController: UIViewController {
    
    enum Model: CaseIterable {
        case other
        case table
        case collection
        
        var title: String {
            switch self {
            case .other:
                return "在UIView上展示空数据"
            case .table:
                return "在UITableView上展示空数据"
            case .collection:
                return "在UICollectionView上展示空数据"
            }
        }
        
        var controller: UIViewController {
            switch self {
            case .other:
                return ExampleViewController()
            case .table:
                return EmptyDataExampleTableViewController()
            case .collection:
                return EmptyDataExampleTableViewController()
            }
        }
    }
    
    let models = Model.allCases
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(models[indexPath.row].controller, animated: true)
    }
}
