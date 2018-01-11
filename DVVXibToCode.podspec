Pod::Spec.new do |s|

s.name         = 'DVVXibToCode'
s.summary      = '根据 xib 文件自动生成属性、添加视图、约束和Getter方法代码。'
s.version      = '1.0.2'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.authors      = { 'devdawei' => '2549129899@qq.com' }
s.homepage     = 'https://github.com/devdawei'

s.osx.deployment_target = '10.10'

s.source       = { :git => 'https://github.com/devdawei/DVVXibToCode.git', :tag => 'v1.0.2' }

s.source_files = 'DVVXibToCode/DVVXibToCode/DVVXibToCode/*.{h,m}'

s.frameworks   = 'Foundation'

s.dependency 'XMLDictionary', '~> 1.4.1'
s.dependency 'PureLayout', '~> 3.0.2'

end