Pod::Spec.new do |s|
  s.name         = "KayakoMessenger"
  s.version      = "0.3.0"
  s.summary      = "The Kayako iOS SDK for integrating Kayako Messenger live chat into your iOS application"
  s.description  = "The Kayako iOS SDK for integrating Kayako Messenger live chat into your iOS application. Supports iOS 9 and above"
  s.homepage     = "https://github.com/kayako/KayakoMessengeriOS"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Robin Malhotra" => "robin.malhotra@kayako.com" }
  s.social_media_url   = "https://twitter.com/codeOfRobin"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/kayako/KayakoMessengeriOS.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*.swift"
  s.documentation_url = 'https://developer.kayako.com/messenger/ios/installation/'
  s.frameworks  = "UIKit"
  s.module_name  = "KayakoMessenger"
  s.ios.resource_bundle = { 'Kayako-Messenger' => 'Resources/**' }
  s.dependency 'Texture'
  s.dependency 'Birdsong'
  s.dependency 'StatefulViewController'
  s.dependency 'NVActivityIndicatorView'
  s.dependency 'Unbox'
  s.dependency 'Wrap'
  s.dependency 'PINCacheTexture'
end
