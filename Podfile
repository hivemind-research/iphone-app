source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

use_frameworks!

pod 'SwiftHTTP', '~> 0.9.5'
pod 'SwiftyJSON', '~> 2.2.0'
pod 'SnapKit'


target 'HiveMindTests' do

end


post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
        end
    end
end
