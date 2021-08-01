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
            if isLoading == false {
                if dataArray.count > 0 {
                    self.view.emptyData?.hide()
                }
                else {
                    self.view.emptyData?.show(with: ExampleEmptyDataState.noMessage)
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
        var emptyData = XYEmptyData()
        
        emptyData.format.contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        emptyData.format.imageSize = CGSize(width: 180, height: 180)
        
        emptyData.delegate = self
        view.emptyData = emptyData
        
        emptyData.show(with: ExampleEmptyDataState.noMessage)
    }

    @objc private func clearData() {
        dataArray.removeAll()
        view.emptyData?.show(with: ExampleEmptyDataState.noMessage)
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
        }
    }
}

extension ExampleViewController: XYEmptyDataDelegate {
    
    func emptyData(_ emptyData: XYEmptyData, didTapContentView view: UIControl) {
        requestData()
    }
    
    func emptyData(_ emptyData: XYEmptyData, didTapButton button: UIButton) {
        self.requestData()
    }
}

extension ExampleViewController: XYEmptyDataAppearable {
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
