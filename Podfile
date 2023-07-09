# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MOGAK' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MOGAK
pod 'SnapKit', '~> 5.6.0'
pod 'Then'
pod 'Alamofire'



post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end

end
