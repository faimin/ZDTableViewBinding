
Pod::Spec.new do |s|

  s.name         = "ZDTableViewBinding"
  s.version      = "0.2"
  s.summary      = "使用`ReactiveObjC`绑定处理tableView的数据,并利用`UITableView+FDTemplateLayoutCell`计算tableViewCell的高度"
  s.homepage     = "https://github.com/faimin/ZDTableViewBinding"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Zero.D.Saber" => "fuxianchao@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { 
    :git => "https://github.com/faimin/ZDTableViewBinding.git", 
    :tag => s.version.to_s
  }

  s.subspec 'ZDProtocols' do |ss|
    ss.source_files = 'ZDTableViewBinding/ZDProtocols/*.h'
  end

  s.subspec 'ZDViewModels' do |ss|
    ss.source_files = 'ZDTableViewBinding/ZDViewModels/*.{h,m}'
    ss.dependency 'ZDTableViewBinding/ZDProtocols'
  end

  s.subspec 'ZDBinding' do |ss|
    ss.source_files = 'ZDTableViewBinding/ZDBinding/*.{h,m}'
    ss.dependency 'ZDTableViewBinding/ZDProtocols'
    ss.dependency 'ZDTableViewBinding/ZDViewModels'
    ss.dependency 'UITableView+FDTemplateLayoutCell', '~> 1.6'
  end

  s.subspec 'ZDBaseViews' do |ss|
    ss.source_files = 'ZDTableViewBinding/ZDBaseViews/*.{h,m}'
    ss.dependency 'ZDTableViewBinding/ZDProtocols'
    ss.dependency 'ZDTableViewBinding/ZDViewModels'
  end

  s.requires_arc = true
  s.static_framework = true
  s.frameworks = 'Foundation', 'UIKit'
  # s.dependency "ReactiveCocoa", "~> 2.5"
  s.dependency 'ReactiveObjC'

end
