//
//  ExampleViewController.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {
    private lazy var dataArray = [[Any]]()
    private lazy var clearButton = UIBarButtonItem(title: "clear", style: .plain, target: self, action: #selector(ExampleViewController.clearData))
    
    private var isLoading = false {
        didSet {
            view.reloadEmptyDataView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = clearButton
        view.backgroundColor = UIColor.white
        setupEmptyDataView()
    }
    

    private func setupEmptyDataView() {
        var emptyData = XYEmptyData(position: .center())
        
        emptyData.bind
            .title {
                $0.text = "这是空数据😁视图"
            }
            .detail {
                $0.text = "暂无数据"
                $0.numberOfLines = 0
            }
            .image {
                $0.image = UIImage(named: "wow")
            }
            .button {
                $0.setTitle("点击重试", for: .normal)
                $0.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
                $0.layer.cornerRadius = 5.0
                $0.layer.masksToBounds = true
            }
            .custom { [weak self] in
                if self?.isLoading == true {
                    let indicatorView = UIActivityIndicatorView(style: .gray)
                    indicatorView.startAnimating()
                    return indicatorView
                }
                return nil
            }
            .position { [weak self] in
                guard let `self` = self else { return .none}
                if self.isLoading == true {
                    return .top(offset: 100)
                }
                return .center(offset: 0)
            }
        
        emptyData.contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        emptyData.imageSize = CGSize(width: 180, height: 180)
        
        emptyData.delegate = self
        view.emptyData = emptyData
        
        emptyData.show(on: self.view, animated: true)
    }

    @objc private func clearData() {
        dataArray.removeAll()
        view.emptyData?.show(on: self.view, animated: true)
        view.reloadEmptyDataView()
    }
}

extension ExampleViewController: XYEmptyDataDelegate {
    
    func emptyData(_ emptyData: XYEmptyData, didTapButton button: UIButton) {
        self.requestData()
    }
    
    fileprivate func requestData() {
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
            if self.dataArray.count > 0 {
                self.view.emptyData?.hide()
            }
        }
    }
}

extension ExampleViewController: XYEmptyDataViewAppearable {
    func emptyData(_ emptyData: XYEmptyData, onApperStatus status: XYEmptyDataAppearStatus) {
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
