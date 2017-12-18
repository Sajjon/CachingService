# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.1'
use_frameworks!

def pods
	pod 'ViewComposer'
	pod 'TinyConstraints'
	pod 'RxSwift'
	pod 'RxOptional'
	pod 'ReachabilitySwift'
	pod 'Cache' # https://github.com/hyperoslo/Cache
	pod 'SwiftDate'
	pod 'Swinject'
	pod 'RxViewController'
	pod 'SwiftyBeaver'
	pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :commit => 'd8a35768015125b74729fd4f9da91bf5dd84e033'
end

workspace 'CachingService'
project 'Example/Example'
project 'CachingService'


target 'Example' do
	project 'Example/Example'
	pods
end

target 'CachingService' do
	project 'CachingService'
	
	pods
end

 target 'CachingServiceTests' do
 	project 'CachingService'
 	
 	pods
    pod 'RxTest'
    pod 'RxBlocking'
    inherit! :search_paths
 end