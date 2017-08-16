

Pod::Spec.new do |s|  
  s.name         = "MGIndexView"
  s.version      = "1.0.0"
  s.summary      = "A custom component for the ecomfe's echarts."
  s.homepage     = "https://github.com/LYM-mg/MGIndexView"
  s.license      = { :type => "MIT", :file => 'LICENSE.md' }
  s.author             = { "LYM-mg" => "1292043630@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/LYM-mg/MGIndexView.git", :tag => s.version}
  s.frameworks   = 'UIKit'
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.requires_arc = true
end
