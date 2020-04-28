# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Kitchen' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Kitchen

pod 'SVProgressHUD'
pod 'ChameleonFramework'
pod 'SideMenuSwift'
pod 'SwiftyJSON'
pod 'Alamofire'
pod 'ObjectMapper'
pod 'Kingfisher'
pod 'IQKeyboardManagerSwift'
pod 'ImageSlideshow', '~> 1.6'
pod 'DLRadioButton', '~> 1.4'
pod "ImageSlideshow/Alamofire"
pod 'GooglePlaces'

# Note it's NOT 'SideMenu'
# https://github.com/kukushi/SideMenu

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end
