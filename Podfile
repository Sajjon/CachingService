# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.1'
use_frameworks!

def pods
	pod 'RxSwift'
	pod 'RxOptional'
	pod 'ReachabilitySwift'
	pod 'SwiftyBeaver'
	pod 'Cache' # https://github.com/hyperoslo/Cache
	pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :commit => 'd8a35768015125b74729fd4f9da91bf5dd84e033'
end

workspace 'CachingService'
project 'Example/Example'
project 'CachingService'


target 'Example' do
	project 'Example/Example'

	pods
	pod 'ViewComposer'
	pod 'TinyConstraints'
	pod 'RxViewController'
	pod 'Swinject'
	pod 'SwiftDate'
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