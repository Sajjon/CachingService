Pod::Spec.new do |s|

  s.name         = "CachingService"
  s.version      = "0.0.1"
  s.summary      = "Fetch, cache data easily using RxSwift"

  s.description  = <<-DESC
                  Easily create your own services extending `Service` and optionally `Persisting` protocol.
                   DESC

  s.homepage     = "https://github.com/Sajjon/CachingService"
  s.license      = 'MIT'
  s.author       = { "Alexander Cyon" => "alex.cyon@gmail.com" }
  s.social_media_url = "https://twitter.com/Redrum_237"
  s.source = { :git => 'https://github.com/Sajjon/CachingService.git', :tag => s.version }
  s.source_files = 'Source/Classes/**/*.swift'
  s.dependency 'Sourcery', '> 0.8'
  s.ios.deployment_target = '11.1'
end
