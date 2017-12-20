Pod::Spec.new do |s|

  s.name         = "CachingService"
  s.version      = "0.0.1"
  s.summary      = "Fetch, cache data easily using RxSwift"

  s.description  = <<-DESC
                  Easily create your own services extending `Service` and optionally `Persisting` protocol.
                   DESC

  s.homepage     = "https://github.com/Sajjon/CachingService"
  s.license = { :type => 'MIT', :file => 'MIT-LICENSE.md' }
  s.author       = { "Alexander Cyon" => "alex.cyon@gmail.com" }
  s.social_media_url = "https://twitter.com/Redrum_237"
  s.source = { :git => 'https://github.com/Sajjon/CachingService.git', :tag => s.version }
  s.source_files = 'Source/Classes/**/*.swift'
  s.dependency 'RxSwift'
  s.dependency 'RxOptional'
  s.dependency 'ReachabilitySwift'
  s.dependency 'SwiftyBeaver'
  s.dependency 'Cache'
  s.dependency 'Alamofire'
  s.ios.deployment_target = '10.0'
end
