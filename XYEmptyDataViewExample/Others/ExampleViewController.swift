//
//  ExampleViewController.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/30.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit
import XYEmptyDataView

/// 在UIView上显示或隐藏空数据视图
class ExampleViewController: UIViewController {
    private lazy var dataArray = [[Any]]()
    private lazy var clearButton = UIBarButtonItem(title: "clear", style: .plain, target: self, action: #selector(ExampleViewController.clearData))
    
    private var isLoading = false {
        didSet {
            if isLoading == false {
                if dataArray.count > 0 {
//                    self.view.emptyData?.hide()
                    self.view.emptyData?.show(with: ExampleEmptyDataState.submitSuccess)
                    clearButton.isEnabled = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = clearButton
        view.backgroundColor = UIColor.white
        setupEmptyDataView()
    }
    

    private func setupEmptyDataView() {
        var emptyData = XYEmptyData.with(state: ExampleEmptyDataState.noMessage)
        
        emptyData.format.contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        emptyData.format.imageSize = CGSize(width: 180, height: 180)
        
        emptyData.delegate = self
        view.emptyData = emptyData
        
        emptyData.show()
    }

    @objc private func clearData() {
        dataArray.removeAll()
        /// 回到初始状态
        view.emptyData?.show()
    }
    
    private func requestData() {
        if isLoading {
            return
        }
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

extension ExampleViewController: XYEmptyDataDelegate {
    func emptyData(_ emptyData: XYEmptyData, didTapButtonInState state: XYEmptyDataState) {
        switch state as? ExampleEmptyDataState {
        case .noMessage:
            requestData()
        default:
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func position(forState state: XYEmptyDataState, inEmptyData emptyData: XYEmptyData) -> XYEmptyData.Position {
        switch state as! ExampleEmptyDataState {
        case .loading:
            return .top()
        default:
            return .center(offset: -50)
        }
    }
    
    func didAppear(forEmptyData emptyData: XYEmptyData) {
        clearButton.isEnabled = false
    }
    func didDisappear(forEmptyData emptyData: XYEmptyData) {
        clearButton.isEnabled = true
    }
}
