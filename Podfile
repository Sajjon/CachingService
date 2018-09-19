# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/eberrydigital/Alamofire.git'

platform :ios, '10.0'
use_frameworks!

def pods
	pod 'RxSwift'
	pod 'RxOptional'
	pod 'ReachabilitySwift'
	pod 'SwiftyBeaver'
	pod 'Cache' # https://github.com/hyperoslo/Cache
	pod 'CodableAlamofire'
	pod 'Alamofire'
end

workspace 'CachingService'
project 'Example/Example'
project 'CachingService'


target 'Example' do
	project 'Example/Example'

	pods
	pod 'ViewComposer', :git => 'https://github.com/Sajjon/ViewComposer.git', :branch => 'master'
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