# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MOGAK' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MOGAK
pod 'SnapKit', '~> 5.6.0'
pod 'Then'
pod 'Alamofire'
pod 'ReusableKit'
pod 'FSCalendar'
pod 'Kingfisher', '~> 5.0'
pod "BSImagePicker", "~> 3.3.1"
pod 'SwiftyJSON', '~> 4.0'
pod 'ExpyTableView'
pod 'lottie-ios'

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end

end
