Pod::Spec.new do |s|
  s.name = 'Daydream'
  s.version = '1.0'
  s.summary = 'Use the Daydream View controller with your iOS app.'
  s.homepage = 'http://github.com/gizmosachin/Daydream'
  s.license = 'MIT'
  s.social_media_url = 'http://twitter.com/gizmosachin'
  s.author = { 'Sachin Patel' => 'me@gizmosachin.com' }
  s.source = { :git => 'https://github.com/gizmosachin/Daydream.git', :tag => s.version }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/*.swift'
  s.requires_arc = true
  s.frameworks = 'Foundation', 'UIKit', 'CoreGraphics', 'CoreBluetooth'
end
