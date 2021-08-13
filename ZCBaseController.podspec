Pod::Spec.new do |s|
#name必须与文件名一致
s.name              = "ZCBaseController"

#更新代码必须修改版本号
s.version           = "1.0.5"
s.summary           = "a ZCBaseController for ios."
s.description       = <<-DESC
It is a ZCBaseController used on iOS, which implement by Objective-C.
DESC
s.homepage          = "https://github.com/ChenZhenChun/ZCBaseController"
s.license           = 'MIT'
s.author            = { "ChenZhenChun" => "346891964@qq.com" }

#submodules 是否支持子模块
s.source            = { :git => "https://github.com/ChenZhenChun/ZCBaseController.git", :tag => s.version, :submodules => true}
s.platform          = :ios, '9.0'
s.requires_arc = true

#source_files路径是相对podspec文件的路径

#核心模块
s.subspec 'ZCBaseController' do |ss|
ss.resources = 'ZCBaseController/ZCBaseController/*.plist'
ss.source_files = 'ZCBaseController/ZCBaseController/*.{h,m}'
ss.public_header_files = 'ZCBaseController/ZCBaseController/*.h'

ss.dependency 'UMengAnalytics-NO-IDFA','4.2.5'
ss.dependency 'FBRetainCycleDetector'
ss.dependency 'ReactiveCocoa','2.5'
ss.dependency 'ZOEEmptyPageDraw','~> 1.0'#空白页处理
ss.dependency 'Macros','~> 1.0'
ss.dependency 'Categorys','~> 1.0'
ss.dependency 'MJRefresh','3.2.0'#下拉刷新，上拉加载更多
ss.dependency 'UITableView+FDTemplateLayoutCell','1.6.0'
ss.dependency 'GLVideoPlayer','~> 1.0'
ss.dependency 'ZOEAlertView','~>1.5'
end

s.frameworks = 'Foundation', 'UIKit'

# s.ios.exclude_files = 'Classes/osx'
# s.osx.exclude_files = 'Classes/ios'
# s.public_header_files = 'Classes/**/*.h'

end
