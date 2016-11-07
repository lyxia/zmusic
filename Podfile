# Podfile
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

use_frameworks!

target 'ZMusic' do
    pod 'RxSwift',    '~> 3.0'
    pod 'RxCocoa',    '~> 3.0'
    pod 'RxDataSources', '~> 1.0.0-beta.1'
    pod 'SnapKit', '~> 3.0.2'
    pod 'DOUAudioStreamer', '0.2.11'
    pod 'Moya', '8.0.0-beta.3'
    pod 'Moya/RxSwift'
    pod 'SDWebImage', '~>3.8'
    pod 'Argo'
    pod 'Curry'
    pod 'Runes'
    pod 'SSZipArchive'
    pod 'PKHUD', '~> 4.0'
end

# RxTests and RxBlocking make the most sense in the context of unit/integration tests
target 'ZMusicTests' do
    pod 'RxBlocking', '~> 3.0.0.alpha.1'
    pod 'RxTests',    '~> 3.0.0.alpha.1'
    pod 'Quick'
    pod 'Nimble' 
    pod 'OHHTTPStubs'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
    end
  end
end