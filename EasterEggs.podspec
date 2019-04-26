Pod::Spec.new do |s|
  s.name             = 'EasterEggs'
  s.version          = '1.0.3'
  s.summary          = 'extensions for macOS/iOS'
  s.swift_version = '4.0'

  s.description      = <<-DESC
extensions for macOS/iOS.
                       DESC

  s.homepage         = 'https://byteamaze.com'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.authors          = 'ByteAmaze CO., LTD.'

  s.source           = {
    :git => 'https://github.com/byteamaze/eastereggs.git',
    :tag => 'EasterEggs-' + s.version.to_s
  }
  s.osx.deployment_target = '10.11'
  s.ios.deployment_target = '9.0'

  s.cocoapods_version = '>= 1.4.0'
  s.static_framework = true
  s.prefix_header_file = false

  s.source_files = 'EasterEggs/*.swift'
  s.osx.framework = 'Cocoa', 'System'

  s.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' =>
      'EasterEggs_VERSION=' + s.version.to_s }
end
