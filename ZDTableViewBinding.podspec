
Pod::Spec.new do |s|

  s.name         = "ZDTableViewBinding"
  s.version      = "0.0.2"
  s.summary      = "使用`ReactiveCocoa`绑定处理tableView的数据,并利用`UITableView+FDTemplateLayoutCell`计算tableViewCell的高度"
  s.homepage     = "https://github.com/faimin/ZDTableViewBinding"
  s.license      = { :type => "MIT", :file => "./Demo/LICENSE" }
  s.author       = { "Zero.D.Saber" => "fuxianchao@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { 
    :git => "https://github.com/faimin/ZDTableViewBinding.git", 
    :tag => s.version
  }

  s.subspec 'ZDBinding' do |ss|
    ss.source_files = 'ZDTableViewBinding/ZDBinding/*.{h,m}'
    ss.dependency "UITableView+FDTemplateLayoutCell", "~> 1.4"
  end

  s.subspec 'ZDProtocols' do |ss|
    ss.source_files = 'ZDTableViewBinding/ZDProtocols/*.h'
  end

  s.subspec 'ZDViewModels' do |ss|
    ss.source_files = 'ZDTableViewBinding/ZDViewModels/*.{h,m}'
  end

  s.subspec 'ZDBaseViews' do |ss|
    ss.source_files = 'ZDTableViewBinding/ZDBaseViews/*.{h,m}'
  end

  s.requires_arc = true
  s.dependency "ReactiveCocoa", "~> 2.5"

end
