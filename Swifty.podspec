Pod::Spec.new do |s|
  s.name             = 'Swifty'
  s.version          = '1.2.0'
  s.summary          = 'Lightweight & Fast Network Abstraction Layer for iOS'

  s.description      = <<-DESC
  Swifty is a modern take on how iOS apps should do networking. Written in Swift, it offers a declarative way to write your network requests and organise them. It has features like Interceptors & Constraints to simplify common networking requirements of apps, and is faster that most exisiting networking libraries.
                       DESC

  s.homepage         = 'https://github.com/Flipkart/Swifty'
  s.license          = { :type => 'Apache, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Rajat Gupta' => 'rajat.g@flipkart.com' }
  s.source           = { :git => 'https://github.com/Flipkart/Swifty.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/**/*'
end
