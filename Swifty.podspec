Pod::Spec.new do |s|
  s.name             = 'Swifty'
  s.version          = '0.9.2'
  s.summary          = 'Lightweight & Fast Network Abstraction Layer for iOS'

  s.description      = <<-DESC
  Swifty is a modern take on how iOS apps should do networking. Written in Swift, it offers a declarative way to write your network requests and organise them. It has features like Interceptors & Constraints to simplify common networking requirements of apps, and is faster that most exisiting networking libraries.
                       DESC

  s.homepage         = 'https://github.com/Flipkart/Swifty'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'Siddharth Gupta' => 'siddharth.gupta@flipkart.com' }
  s.source           = { :git => 'https://github.com/Flipkart/Swifty.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Swifty/Classes/**/*'
end
