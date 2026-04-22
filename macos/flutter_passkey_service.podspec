#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_passkey_service.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_passkey_service'
  s.version          = '0.0.7'
  s.summary          = 'A comprehensive Flutter plugin for Passkey (WebAuthn) integration on macOS.'
  s.description      = <<-DESC
A comprehensive Flutter plugin for seamless Passkey (WebAuthn) integration on iOS, macOS, and Android.
Enable passwordless authentication with biometric security.
                       DESC
  s.homepage         = 'https://github.com/minhtri1401/flutter_passkey_service'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'minhtri1401' => 'tri.dev.dhm@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_passkey_service_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
