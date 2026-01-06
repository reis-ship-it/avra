Pod::Spec.new do |s|
  s.name             = 'SignalFfiNative'
  s.version          = '0.1.0'
  s.summary          = 'SPOTS vendored libsignal-ffi XCFramework'
  s.description      = 'Vendored native libsignal-ffi for Signal Protocol (Dart FFI).'
  s.homepage         = 'https://spots.app'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'SPOTS' => 'dev@spots.app' }
  s.source           = { :path => '.' }

  s.platform         = :ios, '14.0'

  s.vendored_frameworks = [
    'Vendored/SignalFfi.xcframework',
  ]
end

