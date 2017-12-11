# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.1'
use_frameworks!

pod 'ViewComposer'
pod 'TinyConstraints'
pod 'RxSwift'
pod 'RxOptional'
pod 'RxReachability', :git => 'https://github.com/ivanbruel/RxReachability.git'
pod 'RxNuke'
pod 'Swinject'
pod 'RxViewController'
pod 'SwiftyBeaver'
pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :commit => 'd8a35768015125b74729fd4f9da91bf5dd84e033'
pod 'Kingfisher'

target 'CachingService' do

  target 'CachingServiceTests' do
    pod 'RxTest'
    pod 'RxBlocking'
    inherit! :search_paths
  end
end

