
Pod::Spec.new do |s|

  s.name         = "ZDTableViewBinding"
  s.version      = "0.0.1"
  s.summary      = "使用`ReactiveCocoa`绑定处理tableView的数据,并利用`UITableView+FDTemplateLayoutCell`计算tableViewCell的高度"
  s.homepage     = "https://github.com/faimin/ZDTableViewBinding"
  s.license      = { :type => "MIT", :file => "./Demo/LICENSE" }
  s.author       = { "Zero.D.Saber" => "fuxianchao@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { 
    :git => "https://github.com/faimin/ZDTableViewBinding.git", 
    :tag => s.version
  }
  s.source_files  = "ZDTableViewBinding", "ZDTableViewBinding/**/*.{h,m}"
  s.requires_arc = true
  s.dependency "ReactiveCocoa", "~> 2.5"
  s.dependency "UITableView+FDTemplateLayoutCell", "~> 1.4"

end
