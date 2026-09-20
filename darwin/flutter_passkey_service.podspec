#
# Shared iOS + macOS podspec. Kept alongside Package.swift so apps that still
# resolve plugins with CocoaPods continue to work.
# Run `pod lib lint flutter_passkey_service.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_passkey_service'
  s.version          = '0.1.0'
  s.summary          = 'Passkey (WebAuthn) registration and authentication for Flutter on iOS and macOS.'
  s.description      = <<-DESC
A Flutter plugin for seamless Passkey (WebAuthn) integration on iOS, macOS, and Android,
using the native AuthenticationServices framework on Apple platforms.
                       DESC
  s.homepage         = 'https://github.com/minhtri1401/flutter_passkey_service'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'minhtri1401' => 'tri.dev.dhm@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'flutter_passkey_service/Sources/flutter_passkey_service/**/*.swift'

  s.ios.deployment_target = '16.0'
  s.osx.deployment_target = '13.0'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'

  # Flutter.framework does not contain a i386 slice, which is specific to iOS.
  s.ios.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.osx.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.swift_version = '5.0'

  s.resource_bundles = {'flutter_passkey_service_privacy' => ['flutter_passkey_service/Sources/flutter_passkey_service/PrivacyInfo.xcprivacy']}
end
