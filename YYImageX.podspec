Pod::Spec.new do |s|
  s.name             = 'YYImageX'
  s.version          = '1.0'
  s.summary          = 'webp image decoder for macOS'

  s.description      = <<-DESC
Encode/Decode webp image support for macOS.
                       DESC

  s.homepage         = 'https://byteamaze.com'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.authors          = 'ByteAmaze CO., LTD.'

  s.source           = {
    :git => 'https://github.com/byteamaze/yyimagex.git',
    :tag => 'YYImageX-' + s.version.to_s
  }
  s.osx.deployment_target = '10.11'

  s.cocoapods_version = '>= 1.4.0'
  s.static_framework = true
  s.prefix_header_file = false

  s.source_files = 'YYImageX/*.[mh]'
  s.public_header_files = 'YYImageX/*.h'
  s.osx.framework = 'Cocoa'
  s.vendored_frameworks = 'YYImageX/WebP.framework'

  s.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' =>
      'YYImageX_VERSION=' + s.version.to_s }
end
