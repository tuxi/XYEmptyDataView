//
//  ExampleEmptyDataState.swift
//  XYEmptyDataView
//
//  Created by xiaoyuan on 2021/7/31.
//  Copyright © 2021 alpface. All rights reserved.
//

import UIKit
import XYEmptyDataView

enum ExampleEmptyDataState: XYEmptyDataState {
    /// 无本地生活
    case noLocalLife
    /// 无绑定
    case noBinddate
    /// 无消息
    case noMessage
    /// 无网络
    case noInternet
    case error(Error)
    /// 加载中
    case loading
    /// 提交成功
    case submitSuccess
    
    var title: ((UILabel) -> Void)? {
        return {
            switch self {
            case .noLocalLife,
                 .noBinddate:
                $0.text = "空视图测试"
            case .noMessage:
                $0.text = "还没有消息呢"
            case .noInternet:
                $0.text = nil
            case .loading:
                $0.text = nil
            case .error(_):
                $0.text = "未知错误"
            case .submitSuccess:
                $0.text = "提交成功"
            }
        }
    }
    
    var detail: ((UILabel) -> Void)? {
        return {
            $0.numberOfLines = 0
            switch self {
            case .noLocalLife,
                 .noBinddate:
                $0.text = "暂无数据"
            case .noMessage:
                $0.text = "暂无消息"
            case .noInternet:
                $0.text = "暂无网络"
            case .loading:
                $0.text = nil
            case .error(_):
                $0.text = "未知错误"
            case .submitSuccess:
                $0.text = "你的问题已提交至后台，请等待审核"
            }
        }
    }
    
    var button: ((UIButton) -> Void)? {
        return {
            $0.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
            $0.layer.cornerRadius = 5.0
            $0.layer.masksToBounds = true
            switch self {
            case .loading:
                $0.setTitle(nil, for: .normal)
            case .submitSuccess:
                $0.setTitle("好的", for: .normal)
                $0.backgroundColor = UIColor.orange.withAlphaComponent(0.76)
            case .noInternet:
                $0.setTitle("设置", for: .normal)
            default:
                $0.setTitle("点击重试", for: .normal)
            }
        }
    }
    
    var image: ((UIImageView) -> Void)? {
        return {
            switch self {
            case .noLocalLife:
                $0.image = UIImage(named: "icon_default_empty")
            case .noBinddate:
                $0.image = UIImage(named: "empty_noBinddate")
            case .noMessage:
                $0.image = UIImage(named: "empty_noBinddate")
            case .noInternet, .error:
                $0.image = UIImage(named: "empty_network")
            case .submitSuccess:
                $0.image = UIImage(named: "empty_noBinddate")
            case .loading:
                $0.image = nil
            }
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
}
