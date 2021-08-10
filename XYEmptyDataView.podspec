#
#  Be sure to run `pod spec lint XYEmptyDataView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "XYEmptyDataView"
  spec.version      = "0.1"
  spec.summary      = "An empty data view with customizable status, which supports UIView, UITableView and UICollectionView"
  spec.description  = "An empty data view with customizable status, which supports UIView, UITableView and UICollectionView"

  spec.homepage     = "https://github.com/tuxi/XYEmptyDataView"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "xiaoyuan" => "seyooe@gmail.com" }
  spec.social_media_url   = "https://twitter.com/seyooe"

  spec.platform = :ios
  spec.ios.deployment_target = '10.0'
  spec.source       = { :git => "https://github.com/tuxi/XYEmptyDataView.git", :tag => "#{spec.version}" }

  spec.source_files  = "Source/**/*.{swift}"

  spec.framework  = "UIKit"
  spec.swift_version  = '5.0'

end
