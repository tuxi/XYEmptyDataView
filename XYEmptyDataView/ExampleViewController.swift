//
//  ExampleViewController.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit

enum EmptyDataState: XYEmptyDataState {
    case noData
    case noInternet
    case loading
    
    var title: String? {
        switch self {
        case .noData:
            return "这是空数据视图"
        case .loading:
            return nil
        case .noInternet:
            return nil
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
        }
    }
    
    var image: UIImage? {
        switch self {
        case .noData:
            return UIImage(named: "icon_default_empty")
        case .loading:
            return nil
        case .noInternet:
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
            return .top(offset: 0)
        default:
            return .center(offset: -30)
        }
    }
}


class ExampleViewController: UIViewController {
    private lazy var dataArray = [[Any]]()
    private lazy var clearButton = UIBarButtonItem(title: "clear", style: .plain, target: self, action: #selector(ExampleViewController.clearData))
    
    private var isLoading = false {
        didSet {
            if isLoading == false {
                if dataArray.count > 0 {
                    self.view.emptyData?.hide()
                }
                else {
                    self.view.emptyData?.show(with: EmptyDataState.noData)
                }
            }
            else {
                self.view.emptyData?.show(with: EmptyDataState.loading)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = clearButton
        view.backgroundColor = UIColor.white
        setupEmptyDataView()
    }
    

    private func setupEmptyDataView() {
        var emptyData = XYEmptyData()
        
        emptyData.bind
            .button {
                $0.setTitle("点击重试", for: .normal)
                $0.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
                $0.layer.cornerRadius = 5.0
                $0.layer.masksToBounds = true
            }
        
        emptyData.contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        emptyData.imageSize = CGSize(width: 180, height: 180)
        
        emptyData.delegate = self
//        emptyData.dataSource = self
        view.emptyData = emptyData
        
        emptyData.show(with: EmptyDataState.noData)
    }

    @objc private func clearData() {
        dataArray.removeAll()
        view.emptyData?.show(with: EmptyDataState.noData)
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
        }
    }
}

extension ExampleViewController: XYEmptyDataViewAppearable {
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
