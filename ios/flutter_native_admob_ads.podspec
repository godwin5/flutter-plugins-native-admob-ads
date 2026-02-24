#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_native_admob_ads.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_native_admob_ads'
  s.version          = '1.3.0'
  s.summary          = 'A specialized Flutter plugin for AdMob Native Ads with 100% custom UI freedom.'
  s.description      = <<-DESC
A specialized Flutter plugin for AdMob Native Ads that allows for 100% custom UIs built entirely in Flutter, while maintaining native click handling and impression tracking.
                       DESC
  s.homepage         = 'https://github.com/godwin5/flutter-plugins-native-admob-ads'
  s.license          = { :type => 'Zero-Clause BSD', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Google-Mobile-Ads-SDK'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_native_admob_ads_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
