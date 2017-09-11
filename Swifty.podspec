Pod::Spec.new do |s|
  s.name             = 'Swifty'
  s.version          = '0.9.0'
  s.summary          = 'Lightweight & Fast Network Abstraction Layer for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

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
