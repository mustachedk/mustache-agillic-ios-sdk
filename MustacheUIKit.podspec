Pod::Spec.new do |s|
  s.name             = 'MustacheAgillicSDK'
  s.version          = '0.1.0'
  s.summary          = 'Mustache Agillic SDK for iOS'
  s.homepage         = 'https://github.com/mustachedk/mustache-agillic-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Finn Larsen' => 'fl@mustache.dk' }
  s.source           = { :git => 'https://github.com/mustachedk/mustache-agillic-ios-sdk.git', :tag => s.version.to_s }
  s.swift_version    = '5.1'

  s.ios.deployment_target = '11.0'

  s.source_files = 'sources/*'

  s.frameworks = 'UIFoundation'

  s.dependency 'SnowplowTracker'

end
